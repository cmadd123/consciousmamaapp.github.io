// Stripe Subscription Functions - MomRise
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineString, defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const stripe = require('stripe');

// Default creator rev share. Overridden per creator via creator.rev_share
// (number in (0, 1]). Kept in sync with apple_iap_functions.js — both
// files use the same default and the same per-creator override field.
const DEFAULT_CREATOR_REV_SHARE = 0.5;

function getCreatorRevShare(creator) {
  const v = creator?.rev_share;
  if (typeof v === 'number' && v > 0 && v <= 1) return v;
  return DEFAULT_CREATOR_REV_SHARE;
}
const PAYOUT_MIN_CENTS = 2500;
const CREATOR_ONBOARD_RETURN_URL = 'https://momrise.app/creator/?connect=done';
const CREATOR_ONBOARD_REFRESH_URL = 'https://momrise.app/creator/?connect=refresh';

// Firebase Admin is initialized in index.js — just get Firestore
const db = getFirestore();

// Configuration parameters
const stripeSecretKey = defineSecret('STRIPE_SECRET_KEY');
const stripePriceMonthly = defineString('STRIPE_PRICE_MONTHLY');
const stripePriceYearly = defineString('STRIPE_PRICE_YEARLY');
const stripeWebhookSecret = defineSecret('STRIPE_WEBHOOK_SECRET');

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

      // Dedup: if user already has a live subscription, reuse it instead of
      // creating a new one. Prevents duplicate charges when user taps
      // "Start Free Trial" multiple times.
      if (userData.subscription_id) {
        console.log('🔍 Checking existing subscription:', userData.subscription_id);
        try {
          const existing = await stripeClient.subscriptions.retrieve(userData.subscription_id);
          console.log('📊 Existing subscription status:', existing.status);

          if (['trialing', 'active', 'incomplete'].includes(existing.status)) {
            console.log('♻️  Reusing existing subscription — skipping creation');

            const reuseSetupIntent = await stripeClient.setupIntents.create({
              customer: customerId,
              payment_method_types: ['card'],
            });

            const reuseEphemeralKey = await stripeClient.ephemeralKeys.create(
              { customer: customerId },
              { apiVersion: '2024-12-18.acacia' }
            );

            await userDoc.ref.update({
              subscription_status: existing.status,
              current_period_end: new Date(existing.current_period_end * 1000),
            });

            return {
              clientSecret: reuseSetupIntent.client_secret,
              ephemeralKey: reuseEphemeralKey.secret,
              customerId,
              subscriptionId: existing.id,
            };
          }

          console.log('⚠️  Existing subscription is terminal (', existing.status, '), creating new one');
        } catch (err) {
          console.log('⚠️  Could not retrieve existing subscription, creating fresh:', err.message);
        }
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
 * Stripe webhook handler (HTTP endpoint, not callable)
 * Stripe sends POST requests here with event data
 * Verifies signature if STRIPE_WEBHOOK_SECRET is set
 */
exports.stripeWebhook = onRequest(
  { secrets: [stripeSecretKey, stripeWebhookSecret] },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    let event;
    const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

    const webhookSecret = stripeWebhookSecret.value()?.replace(/[\s\r\n]+/g, '');
    if (webhookSecret) {
      try {
        const sig = req.headers['stripe-signature'];
        event = stripeClient.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
      } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        res.status(400).send(`Webhook Error: ${err.message}`);
        return;
      }
    } else {
      event = req.body;
    }

    try {
      switch (event.type) {
        case 'customer.subscription.trial_will_end': {
          const subscription = event.data.object;
          console.log(`Trial ending soon for subscription: ${subscription.id}`);
          break;
        }

        case 'customer.subscription.created': {
          // Fallback: if createSubscription's Firestore write failed
          // (network blip, transient error), this event ensures the user's
          // subscription state lands in Firestore within seconds.
          const subscription = event.data.object;
          const customerId = subscription.customer;

          const usersSnapshot = await db.collection('users')
            .where('stripe_customer_id', '==', customerId)
            .limit(1)
            .get();

          if (!usersSnapshot.empty) {
            const userDoc = usersSnapshot.docs[0];
            const userData = userDoc.data();
            const update = {
              subscription_id: subscription.id,
              subscription_status: subscription.status,
              current_period_end: new Date(subscription.current_period_end * 1000),
            };
            if (subscription.trial_end) {
              update.trial_end = new Date(subscription.trial_end * 1000);
            }
            await userDoc.ref.update(update);
            console.log(`Synced subscription ${subscription.id} for user ${userDoc.id} (status: ${subscription.status})`);
          } else {
            console.log(`No user found for customer ${customerId} — subscription ${subscription.id} orphaned`);
          }
          break;
        }

        case 'customer.subscription.updated': {
          const subscription = event.data.object;
          const customerId = subscription.customer;

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

          const usersSnapshot = await db.collection('users')
            .where('stripe_customer_id', '==', customerId)
            .limit(1)
            .get();

          if (!usersSnapshot.empty) {
            const userDoc = usersSnapshot.docs[0];
            const userData = userDoc.data() || {};
            // Don't revoke comped creators' access when a paid Stripe sub
            // they had alongside the comp ends — they keep the free-forever comp.
            if (userData.is_comped === true) {
              await userDoc.ref.update({
                subscription_id: null,
                subscription_status: 'active',
                subscription_source: 'creator_comp',
              });
            } else {
              await userDoc.ref.update({
                subscription_status: 'canceled',
                subscription_id: null,
              });
            }
          }
          break;
        }

        case 'invoice.payment_succeeded': {
          const invoice = event.data.object;
          await recordCreatorEarning(invoice);
          break;
        }

        case 'invoice.payment_failed': {
          console.log(`Payment failed for invoice: ${event.data.object.id}`);
          break;
        }

        case 'charge.refunded': {
          // Clawback: log a negative earning so the next payout run deducts it.
          const charge = event.data.object;
          await recordRefundClawback(charge);
          break;
        }

        case 'account.updated': {
          // Stripe Connect: flip the creator's onboarded flag when they finish.
          const account = event.data.object;
          await syncConnectAccount(account);
          break;
        }

        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      res.status(200).json({ received: true });
    } catch (error) {
      console.error('Webhook processing error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);

// ── Stripe Connect onboarding ─────────────────────────
// Creators link their bank through Stripe Express. We create one Express
// account per creator the first time they hit "Connect your bank", then
// return a fresh Account Link URL for the hosted onboarding flow.

exports.createCreatorOnboardingLink = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required');
    }
    const uid = request.auth.uid;
    const userPath = `users/${uid}`;

    const creatorSnap = await db.collection('creators')
      .where('user_ref', '==', db.doc(userPath))
      .limit(1)
      .get();
    if (creatorSnap.empty) {
      throw new HttpsError('failed-precondition', 'No creator profile for this user');
    }
    const creatorDoc = creatorSnap.docs[0];
    const creator = creatorDoc.data();

    const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

    let accountId = creator.stripe_connect_account_id;
    if (!accountId) {
      // Country defaults to the value on the creator doc (set at apply
      // time), falls back to the param sent on this call, then US.
      // Stripe Express supports 40+ countries; valid ISO 3166-1 alpha-2.
      const country = (creator.country
        || request.data?.country
        || 'US').toUpperCase();
      const account = await stripeClient.accounts.create({
        type: 'express',
        country,
        email: request.auth.token.email || undefined,
        capabilities: {
          transfers: { requested: true },
        },
        business_type: 'individual',
        metadata: {
          creator_id: creatorDoc.id,
          creator_code: creator.code || '',
          uid,
        },
      });
      accountId = account.id;
      await creatorDoc.ref.update({
        stripe_connect_account_id: accountId,
        stripe_connect_onboarded: false,
        stripe_connect_charges_enabled: false,
        stripe_connect_payouts_enabled: false,
      });
    }

    const link = await stripeClient.accountLinks.create({
      account: accountId,
      refresh_url: CREATOR_ONBOARD_REFRESH_URL,
      return_url: CREATOR_ONBOARD_RETURN_URL,
      type: 'account_onboarding',
    });

    return { url: link.url, accountId };
  }
);

// Returns a one-time Stripe Express login URL so the creator can view
// payouts, update bank info, and download tax docs. Short-lived (~5min).
exports.createCreatorDashboardLink = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required');
    }
    const uid = request.auth.uid;
    const creatorSnap = await db.collection('creators')
      .where('user_ref', '==', db.doc(`users/${uid}`))
      .limit(1)
      .get();
    if (creatorSnap.empty) {
      throw new HttpsError('failed-precondition', 'No creator profile for this user');
    }
    const creator = creatorSnap.docs[0].data();
    if (!creator.stripe_connect_account_id) {
      throw new HttpsError('failed-precondition', 'Connect your bank first');
    }

    const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));
    const link = await stripeClient.accounts.createLoginLink(creator.stripe_connect_account_id);
    return { url: link.url };
  }
);

exports.getCreatorConnectStatus = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required');
    }
    const uid = request.auth.uid;
    const creatorSnap = await db.collection('creators')
      .where('user_ref', '==', db.doc(`users/${uid}`))
      .limit(1)
      .get();
    if (creatorSnap.empty) return { connected: false };
    const creator = creatorSnap.docs[0].data();
    if (!creator.stripe_connect_account_id) return { connected: false };

    const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));
    const account = await stripeClient.accounts.retrieve(creator.stripe_connect_account_id);
    // We create Express accounts with `capabilities: { transfers: { requested: true } }`
    // only — never charges. So `account.charges_enabled` is always false even
    // for fully-onboarded creators. The right "they're done with Stripe" signal
    // for a payouts-only platform is `payouts_enabled`, which flips true once
    // Stripe has verified their bank + identity and they can receive transfers.
    const onboarded = !!(account.details_submitted && account.payouts_enabled);

    await creatorSnap.docs[0].ref.update({
      stripe_connect_onboarded: onboarded,
      stripe_connect_charges_enabled: !!account.charges_enabled,
      stripe_connect_payouts_enabled: !!account.payouts_enabled,
    });

    return {
      connected: true,
      onboarded,
      charges_enabled: !!account.charges_enabled,
      payouts_enabled: !!account.payouts_enabled,
      details_submitted: !!account.details_submitted,
    };
  }
);

// ── Earnings ledger helpers ───────────────────────────

async function syncConnectAccount(account) {
  const snap = await db.collection('creators')
    .where('stripe_connect_account_id', '==', account.id)
    .limit(1)
    .get();
  if (snap.empty) return;
  await snap.docs[0].ref.update({
    // Express accounts are transfers-only (we never requested the charges
    // capability), so charges_enabled stays false even after full onboarding.
    // Use payouts_enabled as the "done" signal — it flips true once Stripe
    // verifies bank + identity.
    stripe_connect_onboarded: !!(account.details_submitted && account.payouts_enabled),
    stripe_connect_charges_enabled: !!account.charges_enabled,
    stripe_connect_payouts_enabled: !!account.payouts_enabled,
  });
}

async function recordCreatorEarning(invoice) {
  if (!invoice || invoice.amount_paid <= 0) return;

  const customerId = invoice.customer;
  if (!customerId) return;

  const userSnap = await db.collection('users')
    .where('stripe_customer_id', '==', customerId)
    .limit(1)
    .get();
  if (userSnap.empty) return;
  const userDoc = userSnap.docs[0];
  const creatorCode = userDoc.data().active_creator_code;
  if (!creatorCode) return;

  const creatorSnap = await db.collection('creators')
    .where('code', '==', creatorCode)
    .limit(1)
    .get();
  if (creatorSnap.empty) return;
  const creatorDoc = creatorSnap.docs[0];
  const creator = creatorDoc.data();

  // Policy: only log earnings once a creator has completed Connect
  // onboarding. Pre-onboarding subs stay with the platform.
  if (!creator.stripe_connect_onboarded) {
    console.log(`Skipping earning for creator ${creatorCode}: not onboarded`);
    return;
  }

  const existing = await db.collection('creator_earnings')
    .where('invoice_id', '==', invoice.id)
    .limit(1)
    .get();
  if (!existing.empty) return;

  const revShare = getCreatorRevShare(creator);
  const creatorCents = Math.round(invoice.amount_paid * revShare);
  await db.collection('creator_earnings').add({
    creator_ref: creatorDoc.ref,
    creator_code: creatorCode,
    user_ref: userDoc.ref,
    invoice_id: invoice.id,
    charge_id: invoice.charge || null,
    gross_cents: invoice.amount_paid,
    creator_cents: creatorCents,
    rev_share: revShare,
    currency: invoice.currency || 'usd',
    period_start: invoice.period_start ? new Date(invoice.period_start * 1000) : null,
    period_end: invoice.period_end ? new Date(invoice.period_end * 1000) : null,
    payout_status: 'pending',
    created_at: FieldValue.serverTimestamp(),
    kind: 'earning',
    environment: 'Production', // Stripe has no sandbox concept here; tag
                               // so the payout/dashboard filters can apply
                               // a single `environment == 'Production'`
                               // query across both payment sources.
  });
}

async function recordRefundClawback(charge) {
  const refunded = charge.amount_refunded;
  if (!refunded || refunded <= 0) return;

  const existingEarning = await db.collection('creator_earnings')
    .where('charge_id', '==', charge.id)
    .where('kind', '==', 'earning')
    .limit(1)
    .get();
  if (existingEarning.empty) return;
  const earning = existingEarning.docs[0].data();

  const existingClawback = await db.collection('creator_earnings')
    .where('charge_id', '==', charge.id)
    .where('kind', '==', 'clawback')
    .limit(1)
    .get();
  if (!existingClawback.empty) return;

  // Use the rev_share stored on the original earning row so refunds
  // mirror what was actually paid, even if the creator's rate has been
  // adjusted since the original transaction. Falls back to the default
  // for legacy rows that pre-date per-creator rates.
  const refundRevShare = earning.rev_share || DEFAULT_CREATOR_REV_SHARE;
  const refundCreatorCents = Math.round(refunded * refundRevShare);
  await db.collection('creator_earnings').add({
    creator_ref: earning.creator_ref,
    creator_code: earning.creator_code,
    user_ref: earning.user_ref,
    invoice_id: earning.invoice_id,
    charge_id: charge.id,
    gross_cents: -refunded,
    creator_cents: -refundCreatorCents,
    rev_share: refundRevShare,
    currency: charge.currency || 'usd',
    payout_status: 'pending',
    created_at: FieldValue.serverTimestamp(),
    kind: 'clawback',
    source_earning_ref: existingEarning.docs[0].ref,
    environment: 'Production',
  });
}

// ── Monthly payout runner ─────────────────────────────
// Runs on the 10th of every month. For each creator with Connect onboarded,
// sums pending earnings (incl. negative clawbacks). If the balance is ≥
// $25, transfers it to their Connect account and marks those ledger docs
// as paid. Sub-threshold balances roll to next month.

exports.runCreatorPayouts = onSchedule(
  {
    schedule: '0 13 10 * *',
    timeZone: 'America/New_York',
    secrets: [stripeSecretKey],
  },
  async () => {
    const stripeClient = stripe(stripeSecretKey.value().replace(/[\s\r\n]+/g, ''));

    // "We pay you when Apple pays us." Payouts run on the 10th with a
    // 45-day holdback, which together guarantee every earning is inside
    // an Apple deposit that has ALREADY landed — the platform never
    // fronts creator money from its own reserves (there are none to
    // front at this stage). Apple pays each fiscal month's sales ~33
    // days after the fiscal month closes, so worst case (a purchase on
    // fiscal day 1) deposits ~65 days later, always before the 10th-of-
    // month sweep that follows the 45-day aging. The old 1st-of-month /
    // 30-35-day design quietly fronted early-month purchases by up to a
    // week. Creator-facing copy (dashboard, FAQ, agreement) states the
    // when-Apple-pays-us framing — keep them in sync with this number.
    const PAYOUT_HOLDBACK_DAYS = 45;
    const holdbackCutoffMs = Date.now() - PAYOUT_HOLDBACK_DAYS * 24 * 60 * 60 * 1000;

    const pendingSnap = await db.collection('creator_earnings')
      .where('payout_status', '==', 'pending')
      .get();

    const buckets = new Map();
    let heldBackCount = 0;
    for (const doc of pendingSnap.docs) {
      const d = doc.data();
      // Skip sandbox earnings entirely. Apple-IAP sandbox rows carry
      // environment: 'Sandbox'; everything else (legacy + Stripe +
      // Apple-Production) treated as production. Legacy rows from
      // before this field shipped default to production so they still
      // pay out.
      if (d.environment === 'Sandbox') continue;
      // Apply the 35-day holdback. Rows younger than this stay pending
      // and become eligible on the next monthly cron run. Applies to
      // both earnings and clawbacks — recent refund clawbacks delay
      // until the matching earning age is met. Net balances always
      // reconcile over time.
      const createdAtMs = d.created_at?.toMillis?.() || 0;
      if (createdAtMs === 0 || createdAtMs > holdbackCutoffMs) {
        heldBackCount++;
        continue;
      }
      const key = d.creator_code;
      if (!buckets.has(key)) buckets.set(key, { docs: [], total: 0, creatorRef: d.creator_ref });
      const bucket = buckets.get(key);
      bucket.docs.push(doc);
      bucket.total += d.creator_cents;
    }
    if (heldBackCount > 0) {
      console.log(`Held back ${heldBackCount} pending rows (younger than ${PAYOUT_HOLDBACK_DAYS} days)`);
    }

    for (const [code, bucket] of buckets) {
      if (bucket.total < PAYOUT_MIN_CENTS) {
        console.log(`Creator ${code}: ${bucket.total} cents pending — below threshold, rolling over`);
        continue;
      }
      const creatorSnap = await bucket.creatorRef.get();
      if (!creatorSnap.exists) continue;
      const creator = creatorSnap.data();
      if (!creator.stripe_connect_onboarded || !creator.stripe_connect_account_id) {
        console.warn(`Creator ${code} has pending earnings but no onboarded Connect account — skipping`);
        continue;
      }

      try {
        const transfer = await stripeClient.transfers.create({
          amount: bucket.total,
          currency: 'usd',
          destination: creator.stripe_connect_account_id,
          description: `MomRise creator payout — ${code}`,
          metadata: { creator_code: code, creator_id: creatorSnap.id },
        });
        const paidAt = FieldValue.serverTimestamp();
        const batch = db.batch();
        for (const doc of bucket.docs) {
          batch.update(doc.ref, {
            payout_status: 'paid',
            payout_id: transfer.id,
            paid_at: paidAt,
          });
        }
        batch.update(creatorSnap.ref, {
          lifetime_payout_cents: FieldValue.increment(bucket.total),
          last_payout_at: paidAt,
          last_payout_cents: bucket.total,
        });
        await batch.commit();
        console.log(`Paid creator ${code}: ${bucket.total} cents via transfer ${transfer.id}`);
      } catch (err) {
        console.error(`Payout failed for creator ${code}:`, err.message);
      }
    }
  }
);
