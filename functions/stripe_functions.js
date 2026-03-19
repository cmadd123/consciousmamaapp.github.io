// Stripe Subscription Functions - MomRise
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const stripe = require('stripe');

// Initialize Firebase Admin if not already initialized
try {
  initializeApp();
} catch (e) {
  // Already initialized
}

const db = getFirestore();

// Configuration parameters
const stripeSecretKey = defineSecret('STRIPE_SECRET_KEY');
const stripePriceMonthly = defineString('STRIPE_PRICE_MONTHLY');
const stripePriceYearly = defineString('STRIPE_PRICE_YEARLY');

/**
 * Create Stripe subscription with 7-day free trial
 *
 * @param {Object} data - { planType: 'monthly' | 'yearly' }
 * @returns {Object} { clientSecret: string, ephemeralKey: string, customerId: string, subscriptionId: string }
 */
exports.createSubscription = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    const { planType } = request.data;

    // Get user ID from authenticated request
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be logged in');
    }
    const userId = request.auth.uid;

    if (!planType || !['monthly', 'yearly'].includes(planType)) {
      throw new HttpsError('invalid-argument', 'Invalid plan. Must be "monthly" or "yearly"');
    }

    try {
      console.log('╔════════════════════════════════════════════════════════════════╗');
      console.log('║ STRIPE SUBSCRIPTION DEBUG - START                              ║');
      console.log('╚════════════════════════════════════════════════════════════════╝');
      console.log('📋 Plan Type:', planType);
      console.log('👤 User ID:', userId);
      console.log('📧 User Email:', request.auth?.token?.email);

      // Clean the secret key - remove ALL whitespace and control characters
      const secretKey = stripeSecretKey.value().replace(/[\s\r\n]+/g, '');
      console.log('🔑 Stripe Key Length:', secretKey.length, '(expected: 107)');
      console.log('🔑 First 10 chars:', secretKey.substring(0, 10));
      console.log('🔑 Last 10 chars:', secretKey.substring(secretKey.length - 10));

      const stripeClient = stripe(secretKey);
      console.log('✅ Stripe client initialized');

      // Get user document
      console.log('📂 Fetching user document from Firestore...');
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.log('❌ User document not found');
        throw new HttpsError('not-found', 'User not found');
      }
      console.log('✅ User document found');

      const userData = userDoc.data();
      const userEmail = userData.email || request.auth?.token?.email;
      console.log('📧 User Email from Firestore:', userEmail);

      if (!userEmail) {
        console.log('❌ No email found');
        throw new HttpsError('invalid-argument', 'User email not found');
      }

      // Check if customer already exists
      let customerId = userData.stripe_customer_id;
      console.log('💳 Existing Stripe Customer ID:', customerId || 'NONE');

      if (!customerId) {
        console.log('🆕 Creating new Stripe customer...');
        const customer = await stripeClient.customers.create({
          email: userEmail,
          metadata: {
            firebase_uid: userId,
          },
        });
        customerId = customer.id;
        console.log('✅ Created Stripe customer:', customerId);

        // Save customer ID to Firestore
        await userDoc.ref.update({
          stripe_customer_id: customerId,
        });
        console.log('✅ Saved customer ID to Firestore');
      }

      // Determine price ID based on plan type
      const priceId = planType === 'monthly'
        ? stripePriceMonthly.value()
        : stripePriceYearly.value();
      console.log('💰 Price ID:', priceId);

      // Create a SetupIntent to collect payment method for trial subscription
      console.log('🔧 Creating SetupIntent...');
      const setupIntent = await stripeClient.setupIntents.create({
        customer: customerId,
        payment_method_types: ['card'],
      });
      console.log('✅ SetupIntent created:', setupIntent.id);
      console.log('🔐 SetupIntent client_secret:', setupIntent.client_secret ? 'EXISTS' : 'NULL');

      // Create subscription with 7-day trial (no immediate charge)
      console.log('📝 Creating subscription with 7-day trial...');
      const subscription = await stripeClient.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        trial_period_days: 7,
        payment_settings: {
          save_default_payment_method: 'on_subscription',
        },
      });
      console.log('✅ Subscription created:', subscription.id);
      console.log('📅 Trial ends:', new Date(subscription.trial_end * 1000).toISOString());
      console.log('📊 Subscription status:', subscription.status);

      // Save subscription info to Firestore
      console.log('💾 Saving subscription info to Firestore...');
      await userDoc.ref.update({
        subscription_id: subscription.id,
        subscription_status: subscription.status,
        subscription_plan: planType,
        trial_end: new Date(subscription.trial_end * 1000),
        current_period_end: new Date(subscription.current_period_end * 1000),
      });
      console.log('✅ Firestore updated');

      // Create ephemeral key for the payment sheet
      console.log('🔑 Creating ephemeral key...');
      const ephemeralKey = await stripeClient.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: '2024-12-18.acacia' }
      );
      console.log('✅ Ephemeral key created');

      const response = {
        clientSecret: setupIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customerId,
        subscriptionId: subscription.id,
      };

      console.log('╔════════════════════════════════════════════════════════════════╗');
      console.log('║ RETURN VALUES                                                  ║');
      console.log('╠════════════════════════════════════════════════════════════════╣');
      console.log('║ clientSecret:', response.clientSecret ? 'EXISTS (' + response.clientSecret.substring(0, 20) + '...)' : 'NULL');
      console.log('║ ephemeralKey:', response.ephemeralKey ? 'EXISTS' : 'NULL');
      console.log('║ customerId:', response.customerId);
      console.log('║ subscriptionId:', response.subscriptionId);
      console.log('╚════════════════════════════════════════════════════════════════╝');

      return response;
    } catch (error) {
      console.log('╔════════════════════════════════════════════════════════════════╗');
      console.log('║ ❌ ERROR OCCURRED                                              ║');
      console.log('╠════════════════════════════════════════════════════════════════╣');
      console.log('║ Error Type:', error.constructor.name);
      console.log('║ Error Message:', error.message);
      console.log('║ Error Code:', error.code || 'N/A');
      if (error.type) {
        console.log('║ Stripe Error Type:', error.type);
      }
      if (error.raw) {
        console.log('║ Raw Error:', JSON.stringify(error.raw, null, 2));
      }
      console.log('║ Stack Trace:');
      console.log(error.stack);
      console.log('╚════════════════════════════════════════════════════════════════╝');
      throw new HttpsError('internal', error.message);
    }
  }
);

/**
 * Cancel subscription at period end
 *
 * Uses authenticated user ID from request.auth.uid
 * @returns {Object} { success: boolean, cancelAt: timestamp }
 */
exports.cancelSubscription = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    // Get user ID from authenticated request
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be logged in');
    }
    const userId = request.auth.uid;

    try {
      const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

      // Get user document
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const subscriptionId = userData.subscription_id;

      if (!subscriptionId) {
        throw new HttpsError('failed-precondition', 'No active subscription found');
      }

      // Cancel subscription at period end
      const subscription = await stripeClient.subscriptions.update(subscriptionId, {
        cancel_at_period_end: true,
      });

      // Update Firestore
      await userDoc.ref.update({
        subscription_status: 'canceling',
        cancel_at: new Date(subscription.cancel_at * 1000),
      });

      return {
        success: true,
        cancelAt: subscription.cancel_at,
      };
    } catch (error) {
      console.error('Error canceling subscription:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);

/**
 * Restore purchases - check subscription status
 *
 * Uses authenticated user ID from request.auth.uid
 * @returns {Object} { hasActiveSubscription: boolean, subscription: object }
 */
exports.restorePurchases = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    // Get user ID from authenticated request
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be logged in');
    }
    const userId = request.auth.uid;

    try {
      const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

      // Get user document
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const subscriptionId = userData.subscription_id;

      if (!subscriptionId) {
        return {
          hasActiveSubscription: false,
          subscription: null,
        };
      }

      // Fetch subscription from Stripe
      const subscription = await stripeClient.subscriptions.retrieve(subscriptionId);

      // Update Firestore with latest status
      await userDoc.ref.update({
        subscription_status: subscription.status,
        current_period_end: new Date(subscription.current_period_end * 1000),
      });

      const isActive = ['active', 'trialing'].includes(subscription.status);

      return {
        hasActiveSubscription: isActive,
        subscription: {
          id: subscription.id,
          status: subscription.status,
          plan: userData.subscription_plan,
          currentPeriodEnd: subscription.current_period_end,
          cancelAtPeriodEnd: subscription.cancel_at_period_end,
        },
      };
    } catch (error) {
      console.error('Error restoring purchases:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);

/**
 * Stripe webhook handler
 * Handles subscription events: trial_will_end, updated, deleted, invoice events
 */
exports.stripeWebhook = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    const event = request.data;

    try {
      const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

      switch (event.type) {
        case 'customer.subscription.trial_will_end': {
          const subscription = event.data.object;
          console.log(`Trial ending soon for subscription: ${subscription.id}`);
          // TODO: Send reminder email via SendGrid
          break;
        }

        case 'customer.subscription.updated': {
          const subscription = event.data.object;
          const customerId = subscription.customer;

          // Find user by customer ID
          const usersSnapshot = await db.collection('users')
            .where('stripe_customer_id', '==', customerId)
            .limit(1)
            .get();

          if (!usersSnapshot.empty) {
            const userDoc = usersSnapshot.docs[0];
            await userDoc.ref.update({
              subscription_status: subscription.status,
              current_period_end: new Date(subscription.current_period_end * 1000),
            });
          }
          break;
        }

        case 'customer.subscription.deleted': {
          const subscription = event.data.object;
          const customerId = subscription.customer;

          // Find user by customer ID
          const usersSnapshot = await db.collection('users')
            .where('stripe_customer_id', '==', customerId)
            .limit(1)
            .get();

          if (!usersSnapshot.empty) {
            const userDoc = usersSnapshot.docs[0];
            await userDoc.ref.update({
              subscription_status: 'canceled',
              subscription_id: null,
            });
          }
          break;
        }

        case 'invoice.payment_succeeded': {
          const invoice = event.data.object;
          console.log(`Payment succeeded for invoice: ${invoice.id}`);
          break;
        }

        case 'invoice.payment_failed': {
          const invoice = event.data.object;
          console.log(`Payment failed for invoice: ${invoice.id}`);
          // TODO: Send payment failed email
          break;
        }

        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      return { received: true };
    } catch (error) {
      console.error('Webhook error:', error);
      throw new HttpsError('internal', error.message);
    }
  }
);
