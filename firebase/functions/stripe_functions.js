const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe?.secret_key || process.env.STRIPE_SECRET_KEY);

/**
 * Stripe Subscription Management for MomRise
 *
 * Pricing:
 * - Monthly: $6.99/month
 * - Yearly: $69.99/year (17% savings)
 *
 * Trial: 7 days free, card required upfront
 *
 * Firestore fields (users collection):
 * - stripe_customer_id: Stripe customer ID
 * - subscription_id: Stripe subscription ID
 * - subscription_status: 'trialing' | 'active' | 'past_due' | 'canceled' | 'incomplete'
 * - subscription_plan: 'monthly' | 'yearly'
 * - trial_end: Timestamp when trial ends
 * - current_period_end: Timestamp when current billing period ends
 */

// Stripe Price IDs (set these after creating products in Stripe Dashboard)
const PRICE_IDS = {
  monthly: process.env.STRIPE_PRICE_MONTHLY || functions.config().stripe?.price_monthly || "price_xxxxx",
  yearly: process.env.STRIPE_PRICE_YEARLY || functions.config().stripe?.price_yearly || "price_xxxxx",
};

/**
 * Create Stripe subscription with 7-day free trial
 *
 * Called from Flutter when user taps "Start Free Trial"
 *
 * Flow:
 * 1. Get or create Stripe customer
 * 2. Create PaymentIntent in setup mode
 * 3. Create ephemeral key for payment sheet
 * 4. Return clientSecret + ephemeralKey
 * 5. Flutter presents payment sheet
 * 6. After card collected, create subscription
 */
exports.createSubscription = functions.https.onCall(async (data, context) => {
  try {
    // Ensure user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const uid = context.auth.uid;
    const { planType } = data; // 'monthly' or 'yearly'

    if (!planType || !['monthly', 'yearly'].includes(planType)) {
      throw new functions.https.HttpsError("invalid-argument", "planType must be 'monthly' or 'yearly'");
    }

    console.log(`Creating ${planType} subscription for user ${uid}`);

    // Get user data
    const userRef = admin.firestore().collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const userData = userDoc.data();
    const email = userData.email || context.auth.token.email;

    // Get or create Stripe customer
    let customerId = userData.stripe_customer_id;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: email,
        metadata: {
          firebaseUID: uid,
        },
      });
      customerId = customer.id;

      // Save customer ID to Firestore
      await userRef.update({
        stripe_customer_id: customerId,
      });

      console.log(`Created new Stripe customer: ${customerId}`);
    }

    // Create ephemeral key for payment sheet
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2023-10-16' }
    );

    // Create subscription with trial
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: PRICE_IDS[planType] }],
      trial_period_days: 7,
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
      metadata: {
        firebaseUID: uid,
        planType: planType,
      },
    });

    // Get client secret from payment intent
    const clientSecret = subscription.latest_invoice.payment_intent.client_secret;

    // Update Firestore with subscription info
    const trialEnd = admin.firestore.Timestamp.fromMillis(subscription.trial_end * 1000);
    const currentPeriodEnd = admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000);

    await userRef.update({
      subscription_id: subscription.id,
      subscription_status: subscription.status,
      subscription_plan: planType,
      trial_end: trialEnd,
      current_period_end: currentPeriodEnd,
    });

    console.log(`Created subscription ${subscription.id} for user ${uid}`);

    return {
      clientSecret: clientSecret,
      ephemeralKey: ephemeralKey.secret,
      customerId: customerId,
      subscriptionId: subscription.id,
    };

  } catch (error) {
    console.error("Error creating subscription:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Cancel subscription at end of billing period
 *
 * Doesn't charge for next month, user keeps access until period ends
 */
exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const uid = context.auth.uid;

    // Get user data
    const userRef = admin.firestore().collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const subscriptionId = userDoc.data().subscription_id;

    if (!subscriptionId) {
      throw new functions.https.HttpsError("not-found", "No active subscription");
    }

    // Cancel at end of period (not immediately)
    await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    // Update Firestore
    await userRef.update({
      subscription_status: 'canceled',
    });

    console.log(`Canceled subscription ${subscriptionId} for user ${uid}`);

    return { success: true };

  } catch (error) {
    console.error("Error canceling subscription:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Restore purchases (for users who reinstall app or switch devices)
 *
 * Fetches subscription status from Stripe and updates Firestore
 */
exports.restorePurchases = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const uid = context.auth.uid;

    // Get user data
    const userRef = admin.firestore().collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const customerId = userDoc.data().stripe_customer_id;

    if (!customerId) {
      return { hasSubscription: false };
    }

    // Fetch subscriptions from Stripe
    const subscriptions = await stripe.subscriptions.list({
      customer: customerId,
      status: 'all',
      limit: 1,
    });

    if (subscriptions.data.length === 0) {
      return { hasSubscription: false };
    }

    const subscription = subscriptions.data[0];

    // Update Firestore with latest subscription info
    const trialEnd = subscription.trial_end ? admin.firestore.Timestamp.fromMillis(subscription.trial_end * 1000) : null;
    const currentPeriodEnd = admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000);

    await userRef.update({
      subscription_id: subscription.id,
      subscription_status: subscription.status,
      trial_end: trialEnd,
      current_period_end: currentPeriodEnd,
    });

    console.log(`Restored subscription ${subscription.id} for user ${uid}`);

    return {
      hasSubscription: subscription.status === 'active' || subscription.status === 'trialing',
      status: subscription.status,
    };

  } catch (error) {
    console.error("Error restoring purchases:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Stripe Webhook Handler
 *
 * Handles subscription events:
 * - customer.subscription.trial_will_end (2 days before trial ends)
 * - customer.subscription.updated (subscription status changed)
 * - customer.subscription.deleted (subscription canceled/expired)
 * - invoice.payment_succeeded (payment successful)
 * - invoice.payment_failed (payment failed)
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = functions.config().stripe?.webhook_secret || process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  console.log(`Received webhook: ${event.type}`);

  try {
    switch (event.type) {
      case 'customer.subscription.trial_will_end': {
        const subscription = event.data.object;
        const uid = subscription.metadata.firebaseUID;

        if (uid) {
          console.log(`Trial ending soon for user ${uid}`);
          // TODO: Send push notification/email reminder
        }
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object;
        const uid = subscription.metadata.firebaseUID;

        if (uid) {
          const userRef = admin.firestore().collection("users").doc(uid);
          const trialEnd = subscription.trial_end ? admin.firestore.Timestamp.fromMillis(subscription.trial_end * 1000) : null;
          const currentPeriodEnd = admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000);

          await userRef.update({
            subscription_status: subscription.status,
            trial_end: trialEnd,
            current_period_end: currentPeriodEnd,
          });

          console.log(`Updated subscription ${subscription.id} for user ${uid}: ${subscription.status}`);
        }
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object;
        const uid = subscription.metadata.firebaseUID;

        if (uid) {
          const userRef = admin.firestore().collection("users").doc(uid);

          await userRef.update({
            subscription_status: 'canceled',
          });

          console.log(`Subscription ${subscription.id} deleted for user ${uid}`);
        }
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object;
        const subscriptionId = invoice.subscription;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const uid = subscription.metadata.firebaseUID;

          if (uid) {
            console.log(`Payment succeeded for user ${uid}`);
            // Subscription status will be updated by customer.subscription.updated event
          }
        }
        break;
      }

      case 'invoice.payment_failed': {
        const invoice = event.data.object;
        const subscriptionId = invoice.subscription;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const uid = subscription.metadata.firebaseUID;

          if (uid) {
            console.log(`Payment failed for user ${uid}`);
            // TODO: Send notification to update payment method
          }
        }
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.status(200).json({ received: true });

  } catch (error) {
    console.error("Error handling webhook:", error);
    res.status(500).send("Webhook handler failed");
  }
});
