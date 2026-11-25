// MomRise — server-side subscription entitlements
//
// Why this file exists
// --------------------
// The paywall reads users/{uid}.subscription_status / free_trial_start.
// Until this change the app wrote those fields itself after a store
// purchase, and Firestore rules let any user write their own doc — so any
// user could grant themselves premium. Entitlement fields are now written
// ONLY by Cloud Functions (admin SDK), after verifying the purchase with
// Apple / Google. firestore.rules blocks client writes to those fields
// (deployed LAST — see ROLLOUT_SECURITY_FIXES.md for the staged rollout).
//
// Exports:
//   verifyStorePurchase      callable — app sends the store's verification
//                            data after a purchase/restore; we verify and
//                            write the entitlement.
//   auditUserEntitlementWrites  Firestore trigger on users/{uid} — interim
//                            safety net while old app versions (which still
//                            write subscription_status from the client) are
//                            in the wild. Also stamps free_trial_start
//                            server-side when onboarding completes without it.
//   refreshStoreEntitlements daily — re-checks Google Play subs whose
//                            verified expiry has passed.
//   writeStoreEntitlement / PROTECTED_USER_FIELDS — shared helpers.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { GoogleAuth } = require('google-auth-library');
const crypto = require('crypto');

// App-Specific Shared Secret from App Store Connect. Only used for the
// StoreKit 1 receipt fallback (legacy /verifyReceipt). StoreKit 2 JWS
// transactions are verified offline against Apple's root CA and need no
// secret. Create with: firebase functions:secrets:set APPLE_IAP_SHARED_SECRET
const appleSharedSecret = defineSecret('APPLE_IAP_SHARED_SECRET');

const IOS_BUNDLE_ID = 'com.momrise.app';
const ANDROID_PACKAGE_NAME = 'com.momrise.app';

// Store product id → plan label. Same ids on both stores (iap_service.dart).
const PRODUCT_PLANS = {
  momrise_month: 'monthly',
  momrise_year: 'annual',
};

// ── Rollout switches ────────────────────────────────────────────────
// Interim trigger behaviour while old app versions still write
// entitlement fields from the client (before the new firestore.rules are
// deployed):
//   'audit'   — log unverified client writes to entitlement_audit (default).
//   'enforce' — ALSO revert them. Do NOT use while old iOS builds are in
//               the wild: their (legit) purchases can't be verified from a
//               bare transaction id, so they would be reverted too.
const ENTITLEMENT_TRIGGER_MODE = 'audit';

// When false (default), store expiry / refund signals are only LOGGED and
// users keep premium — which matches today's behaviour (the old client
// wrote 'active' once and nothing ever downgraded it). Flip to true once
// the logs look right to make expiries/refunds actually revoke access.
const STORE_DOWNGRADE_ON_EXPIRY = false;

// Every users/{uid} field that grants or describes premium. Client writes
// to these are blocked by firestore.rules (keep the two lists in sync!).
// free_trial_start is handled separately: client may set it ONCE to
// request.time (serverTimestamp) at end of onboarding.
const PROTECTED_USER_FIELDS = [
  'subscription_status',
  'subscription_plan',
  'subscription_source',
  'subscription_id',
  'subscription_updated_at',
  'subscription_expires_at',
  'stripe_customer_id',
  'current_period_end',
  'trial_end',
  'cancel_at',
  'is_comped',
  'comped_at',
  'comped_by',
  'comped_reason',
  'comp_revoked_at',
  'apple_product_id',
  'apple_transaction_id',
  'apple_original_transaction_id',
  'google_product_id',
  'google_order_id',
  'google_purchase_token',
  'store_environment',
  'entitlement_verified_at',
  'entitlement_flag',
];

// ── Small helpers ───────────────────────────────────────────────────

function sha256(s) {
  return crypto.createHash('sha256').update(String(s)).digest('hex');
}

function valuesEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return a == b; // null vs undefined → equal
  if (typeof a.isEqual === 'function') {
    try { return a.isEqual(b); } catch (_) { return false; }
  }
  try { return JSON.stringify(a) === JSON.stringify(b); } catch (_) { return false; }
}

function decodeJwsPayload(jws) {
  const parts = String(jws).split('.');
  if (parts.length !== 3) return null;
  try {
    const b64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4);
    return JSON.parse(Buffer.from(padded, 'base64').toString('utf8'));
  } catch (_) {
    return null;
  }
}

function looksLikeJws(s) {
  return typeof s === 'string' && s.startsWith('eyJ') && s.split('.').length === 3;
}

// ── Apple verification ──────────────────────────────────────────────

// StoreKit 2: serverVerificationData is the signed transaction (JWS).
// Verified offline against the vendored Apple Root CA G3 using the same
// SignedDataVerifier the App Store Server Notifications webhook uses.
async function verifyAppleJws(jws) {
  // Lazy require: apple_iap_functions requires this module too.
  const { getVerifier } = require('./apple_iap_functions');
  const peek = decodeJwsPayload(jws) || {};
  const env = (peek.environment || peek.data?.environment) === 'Sandbox'
    ? 'Sandbox'
    : 'Production';
  const tx = await getVerifier(env).verifyAndDecodeTransaction(jws);
  if (tx.bundleId !== IOS_BUNDLE_ID) {
    throw new Error(`bundle mismatch: ${tx.bundleId}`);
  }
  if (!PRODUCT_PLANS[tx.productId]) {
    throw new Error(`unknown product: ${tx.productId}`);
  }
  const expiresAtMs = Number(tx.expiresDate || 0);
  return {
    source: 'apple_iap',
    productId: tx.productId,
    transactionId: String(tx.transactionId || ''),
    originalTransactionId: String(tx.originalTransactionId || tx.transactionId || ''),
    expiresAtMs,
    active: !tx.revocationDate && expiresAtMs > Date.now(),
    accountToken: tx.appAccountToken || null,
    environment: env,
  };
}

// StoreKit 1 fallback: serverVerificationData is the base64 app receipt.
// Apple's legacy /verifyReceipt endpoint is deprecated but still
// operational; production first, then sandbox on status 21007.
async function verifyAppleReceipt(receiptB64) {
  const secret = (appleSharedSecret.value() || '').trim();
  if (!secret) throw new Error('APPLE_IAP_SHARED_SECRET not configured');
  const body = JSON.stringify({
    'receipt-data': receiptB64,
    password: secret,
    'exclude-old-transactions': true,
  });
  const post = async (url) => {
    const r = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
    });
    return r.json();
  };
  let env = 'Production';
  let data = await post('https://buy.itunes.apple.com/verifyReceipt');
  if (data.status === 21007) {
    env = 'Sandbox';
    data = await post('https://sandbox.itunes.apple.com/verifyReceipt');
  }
  if (data.status !== 0) throw new Error(`verifyReceipt status ${data.status}`);
  if (data.receipt?.bundle_id !== IOS_BUNDLE_ID) {
    throw new Error(`bundle mismatch: ${data.receipt?.bundle_id}`);
  }
  const infos = (data.latest_receipt_info || [])
    .filter((t) => PRODUCT_PLANS[t.product_id]);
  if (!infos.length) throw new Error('no MomRise subscription in receipt');
  // Latest-expiring transaction wins.
  infos.sort((a, b) => Number(b.expires_date_ms || 0) - Number(a.expires_date_ms || 0));
  const t = infos[0];
  const expiresAtMs = Number(t.expires_date_ms || 0);
  return {
    source: 'apple_iap',
    productId: t.product_id,
    transactionId: String(t.transaction_id || ''),
    originalTransactionId: String(t.original_transaction_id || t.transaction_id || ''),
    expiresAtMs,
    active: !t.cancellation_date_ms && expiresAtMs > Date.now(),
    accountToken: t.app_account_token || null,
    environment: env,
  };
}

// ── Google Play verification ────────────────────────────────────────
// Uses the Android Publisher API with the functions' default service
// account (Application Default Credentials). That service account must be
// invited in Play Console → Users and permissions with "View app
// information" + "View financial data" + "Manage orders and subscriptions"
// for MomRise, and the "Google Play Android Developer API" must be enabled
// in the GCP project. See ROLLOUT_SECURITY_FIXES.md.

let _playAuth = null;
async function playApiGet(url) {
  if (!_playAuth) {
    _playAuth = new GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
  }
  const client = await _playAuth.getClient();
  const res = await client.request({ url, method: 'GET' });
  return res.data;
}

async function verifyGooglePurchase(purchaseToken) {
  const url =
    'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/' +
    `${ANDROID_PACKAGE_NAME}/purchases/subscriptionsv2/tokens/` +
    encodeURIComponent(purchaseToken);
  const data = await playApiGet(url);
  const item = (data.lineItems || []).find((li) => PRODUCT_PLANS[li.productId]);
  if (!item) throw new Error('no MomRise product on this purchase token');
  const expiresAtMs = item.expiryTime ? Date.parse(item.expiryTime) : 0;
  const state = data.subscriptionState;
  const active =
    state === 'SUBSCRIPTION_STATE_ACTIVE' ||
    state === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD' ||
    // Canceled = auto-renew off; still entitled until expiry.
    (state === 'SUBSCRIPTION_STATE_CANCELED' && expiresAtMs > Date.now());
  // Renewal order ids are "<base>..N"; the base is stable for the sub.
  const orderId = data.latestOrderId || '';
  return {
    source: 'google_play',
    productId: item.productId,
    orderId,
    orderBase: orderId.split('..')[0] || null,
    purchaseToken,
    expiresAtMs,
    active,
    state,
    accountToken: data.externalAccountIdentifiers?.obfuscatedExternalAccountId || null,
    environment: data.testPurchase ? 'Sandbox' : 'Production',
  };
}

// ── Entitlement write ───────────────────────────────────────────────

function bindingKey(v) {
  if (v.source === 'apple_iap') return `apple_${v.originalTransactionId}`;
  return `google_${v.orderBase ? sha256(v.orderBase) : sha256(v.purchaseToken)}`;
}

/**
 * Write a verified store entitlement onto users/{uid}. Binds the store
 * subscription to the first Firebase account that claims it, so one
 * purchase can't unlock unlimited accounts. A different account claiming
 * the same subscription gets 'already-exists' — clear the binding doc in
 * store_purchase_bindings/ by hand if a real customer switched accounts.
 */
async function writeStoreEntitlement(uid, v, { allowRebind = false } = {}) {
  const db = getFirestore();
  const userRef = db.collection('users').doc(uid);
  const bindRef = db.collection('store_purchase_bindings').doc(bindingKey(v));
  const plan = PRODUCT_PLANS[v.productId] || 'monthly';

  await db.runTransaction(async (t) => {
    const [userSnap, bindSnap] = await Promise.all([t.get(userRef), t.get(bindRef)]);
    if (bindSnap.exists && bindSnap.data().uid !== uid && !allowRebind) {
      throw new HttpsError(
        'already-exists',
        'This subscription is already linked to another MomRise account.',
      );
    }
    const user = userSnap.exists ? userSnap.data() : {};
    const update = {
      subscription_status: v.active ? 'active' : 'expired',
      subscription_plan: plan,
      subscription_source: v.source,
      subscription_updated_at: FieldValue.serverTimestamp(),
      subscription_expires_at: v.expiresAtMs ? Timestamp.fromMillis(v.expiresAtMs) : null,
      store_environment: v.environment || null,
      entitlement_verified_at: FieldValue.serverTimestamp(),
    };
    if (v.source === 'apple_iap') {
      update.apple_product_id = v.productId;
      update.apple_transaction_id = v.transactionId;
      update.apple_original_transaction_id = v.originalTransactionId;
    } else {
      update.google_product_id = v.productId;
      update.google_order_id = v.orderId || null;
      update.google_purchase_token = v.purchaseToken;
    }
    // Old client code stamped free_trial_start on purchase so the trial
    // gate had a baseline; keep that, but never reset an existing one.
    if (user.free_trial_start == null) {
      update.free_trial_start = FieldValue.serverTimestamp();
    }
    t.set(userRef, update, { merge: true });
    t.set(bindRef, {
      uid,
      source: v.source,
      product_id: v.productId,
      updated_at: FieldValue.serverTimestamp(),
    }, { merge: true });
  });
}

// ── Callable: verifyStorePurchase ───────────────────────────────────
// data: { platform: 'ios'|'android', productId, purchaseId,
//         verificationData: PurchaseDetails.verificationData.serverVerificationData }
// returns: { active: bool, plan, expiresAt (ms) }
exports.verifyStorePurchase = onCall(
  { secrets: [appleSharedSecret], timeoutSeconds: 60 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required');
    }
    const uid = request.auth.uid;
    const platform = String(request.data?.platform || '');
    const verificationData = String(request.data?.verificationData || '');
    if (!['ios', 'android'].includes(platform)) {
      throw new HttpsError('invalid-argument', 'platform must be ios or android');
    }
    if (!verificationData || verificationData.length > 200000) {
      throw new HttpsError('invalid-argument', 'verificationData missing or too large');
    }

    let v;
    try {
      if (platform === 'ios') {
        v = looksLikeJws(verificationData)
          ? await verifyAppleJws(verificationData)
          : await verifyAppleReceipt(verificationData);
      } else {
        v = await verifyGooglePurchase(verificationData);
      }
    } catch (e) {
      console.warn(`[entitlements] verify failed uid=${uid} platform=${platform}: ${e.message}`);
      throw new HttpsError('permission-denied', 'Could not verify this purchase with the store.');
    }

    // The app tags every purchase with users/{uid}.apple_app_account_token
    // (Apple appAccountToken / Google obfuscatedAccountId). If the store
    // reports a token, it must be this user's.
    const db = getFirestore();
    const userSnap = await db.collection('users').doc(uid).get();
    const myToken = userSnap.exists ? userSnap.data().apple_app_account_token : null;
    if (v.accountToken && myToken && v.accountToken.toLowerCase() !== String(myToken).toLowerCase()) {
      console.warn(`[entitlements] account token mismatch uid=${uid} tx=${v.originalTransactionId || v.orderId}`);
      throw new HttpsError('permission-denied', 'This purchase belongs to a different account.');
    }

    if (!v.active) {
      // Expired/revoked transaction (e.g. an old one replayed by restore).
      // Don't downgrade from a client-initiated call — just report.
      console.log(`[entitlements] inactive ${v.source} purchase for uid=${uid} (expires ${v.expiresAtMs})`);
      return { active: false, plan: PRODUCT_PLANS[v.productId] || null, expiresAt: v.expiresAtMs || null };
    }

    await writeStoreEntitlement(uid, v);
    console.log(`[entitlements] verified ${v.source} ${v.productId} for uid=${uid} env=${v.environment}`);
    return { active: true, plan: PRODUCT_PLANS[v.productId], expiresAt: v.expiresAtMs || null };
  },
);

// ── Trigger: interim audit of client entitlement writes ─────────────
// Server writes always change entitlement_verified_at in the same write
// (stripe_functions.js, index.js comp/exempt paths, this file). A change
// to a protected field WITHOUT that marker changing came from a client
// (an old app version, or someone tampering). Until the new rules are
// deployed we can't block those writes, so we:
//   - google_play: verify the purchase token the old client stored; if it
//     verifies, stamp the verified entitlement (marker set → no flag).
//   - everything else: write an entitlement_audit row (and revert in
//     'enforce' mode).
// After the rules ship this trigger stays useful as a tripwire (it should
// then only ever see server writes) plus the free_trial_start backfill.
exports.auditUserEntitlementWrites = onDocumentWritten(
  { document: 'users/{uid}', timeoutSeconds: 60 },
  async (event) => {
    const before = event.data?.before?.exists ? event.data.before.data() : null;
    const after = event.data?.after?.exists ? event.data.after.data() : null;
    if (!after) return; // deleted
    const uid = event.params.uid;
    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);
    const prev = before || {};

    // 1) free_trial_start backfill. The trial gate treats a missing
    //    free_trial_start as "still onboarding" and lets the user through,
    //    so a client that flips onboarding_completed without it would get
    //    an endless trial. Stamp it server-side on that transition only
    //    (legacy users who onboarded long ago are untouched).
    if (prev.onboarding_completed !== true &&
        after.onboarding_completed === true &&
        after.free_trial_start == null) {
      await userRef.set({ free_trial_start: FieldValue.serverTimestamp() }, { merge: true });
      console.log(`[entitlements] backfilled free_trial_start for ${uid}`);
    }

    // 2) Entitlement audit.
    const changed = PROTECTED_USER_FIELDS.filter(
      (k) => k !== 'entitlement_verified_at' && !valuesEqual(prev[k], after[k]),
    );
    // free_trial_start: first set is fine (onboarding), changing or
    // removing an existing value is not.
    if (prev.free_trial_start != null && !valuesEqual(prev.free_trial_start, after.free_trial_start)) {
      changed.push('free_trial_start');
    }
    if (!changed.length) return;
    if (!valuesEqual(prev.entitlement_verified_at, after.entitlement_verified_at)) {
      return; // server write
    }

    // Old Android builds store google_purchase_token — we can verify it.
    if (after.subscription_source === 'google_play' &&
        typeof after.google_purchase_token === 'string' &&
        after.google_purchase_token &&
        ['active', 'trialing'].includes(after.subscription_status)) {
      try {
        const v = await verifyGooglePurchase(after.google_purchase_token);
        if (v.active) {
          await writeStoreEntitlement(uid, v);
          console.log(`[entitlements] verified legacy client google_play write for ${uid}`);
          return;
        }
      } catch (e) {
        console.warn(`[entitlements] legacy google verify failed for ${uid}: ${e.message}`);
      }
    }

    const grantsPremium =
      ['active', 'trialing'].includes(after.subscription_status) &&
      !['active', 'trialing'].includes(prev.subscription_status);
    const auditRow = {
      uid,
      changed_fields: changed,
      before: Object.fromEntries(changed.map((k) => [k, prev[k] ?? null])),
      after: Object.fromEntries(changed.map((k) => [k, after[k] ?? null])),
      grants_premium: grantsPremium,
      source: after.subscription_source || null,
      mode: ENTITLEMENT_TRIGGER_MODE,
      at: FieldValue.serverTimestamp(),
    };
    await db.collection('entitlement_audit').add(auditRow);
    console.warn(`[entitlements] UNVERIFIED client entitlement write uid=${uid} fields=${changed.join(',')}`);

    if (ENTITLEMENT_TRIGGER_MODE === 'enforce') {
      const revert = { entitlement_verified_at: FieldValue.serverTimestamp() };
      for (const k of changed) {
        revert[k] = prev[k] === undefined ? FieldValue.delete() : prev[k];
      }
      await userRef.set(revert, { merge: true });
      console.warn(`[entitlements] reverted client entitlement write for ${uid}`);
    }
  },
);

// ── Scheduled: refresh expired Google Play entitlements ─────────────
// No Play Real-Time Developer Notifications yet, so renewals/cancels are
// picked up lazily: once a day, re-verify Google subs whose last verified
// expiry has passed. (Apple renewals/expiries arrive via the
// appleNotification webhook.) Uses the users(subscription_source,
// subscription_status, subscription_expires_at) composite index in
// firestore.indexes.json.
exports.refreshStoreEntitlements = onSchedule(
  { schedule: 'every day 04:00', timeZone: 'America/Chicago', timeoutSeconds: 540 },
  async () => {
    const db = getFirestore();
    const snap = await db.collection('users')
      .where('subscription_source', '==', 'google_play')
      .where('subscription_status', '==', 'active')
      .where('subscription_expires_at', '<', Timestamp.now())
      .limit(500)
      .get();
    let renewed = 0, expired = 0, errors = 0;
    for (const doc of snap.docs) {
      const u = doc.data();
      if (!u.google_purchase_token) continue;
      try {
        const v = await verifyGooglePurchase(u.google_purchase_token);
        if (v.active) {
          await writeStoreEntitlement(doc.id, v, { allowRebind: true });
          renewed++;
        } else if (STORE_DOWNGRADE_ON_EXPIRY) {
          await writeStoreEntitlement(doc.id, v, { allowRebind: true });
          expired++;
        } else {
          console.log(`[entitlements] (dry-run) would expire google_play user ${doc.id} state=${v.state}`);
          expired++;
        }
      } catch (e) {
        errors++;
        console.warn(`[entitlements] refresh failed for ${doc.id}: ${e.message}`);
      }
    }
    console.log(`[entitlements] refresh: renewed=${renewed} expired=${expired} errors=${errors} downgrade=${STORE_DOWNGRADE_ON_EXPIRY}`);
  },
);

module.exports.PROTECTED_USER_FIELDS = PROTECTED_USER_FIELDS;
module.exports.PRODUCT_PLANS = PRODUCT_PLANS;
module.exports.STORE_DOWNGRADE_ON_EXPIRY = STORE_DOWNGRADE_ON_EXPIRY;
module.exports.writeStoreEntitlement = writeStoreEntitlement;
module.exports.verifyGooglePurchase = verifyGooglePurchase;
