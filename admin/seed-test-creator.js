#!/usr/bin/env node
/**
 * One-shot: provision a test creator with a known code, pre-onboarded so
 * webhook-side earning verification doesn't get gated by Stripe Connect.
 *
 *   node seed-test-creator.js <email> <code> [--name "Name"]
 *
 * Example:
 *   node seed-test-creator.js collinjmaddox@gmail.com STONE45 --name "Collin Maddox"
 *
 * Same setup as approve-creator.js — needs admin/service-account.json
 * downloaded from Firebase Console → Project settings → Service accounts.
 * Idempotent: if a creator already exists for this user, prints the
 * existing code and exits rather than clobbering.
 */

const admin = require('firebase-admin');
const path = require('path');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'service-account.json');
try {
  admin.initializeApp({
    credential: admin.credential.cert(require(SERVICE_ACCOUNT_PATH)),
  });
} catch (err) {
  console.error('\n✗ Could not load service-account.json from', SERVICE_ACCOUNT_PATH);
  console.error('  Download it from Firebase Console → Project settings → Service accounts.');
  console.error('  Error:', err.message, '\n');
  process.exit(1);
}
const db = admin.firestore();
const auth = admin.auth();

const args = process.argv.slice(2);
const email = args.find((a) => !a.startsWith('--') && a.includes('@'));
const code = (args.find((a) => !a.startsWith('--') && !a.includes('@')) || '').toUpperCase();
const flag = (n) => {
  const i = args.indexOf(`--${n}`);
  return i >= 0 ? args[i + 1] : null;
};
let name = flag('name');

if (!email || !code) {
  console.error(
    '\nUsage: node seed-test-creator.js <email> <CODE> [--name "Display Name"]\n',
  );
  process.exit(1);
}
if (!/^[A-Z0-9]{3,20}$/.test(code)) {
  console.error('Code must be 3-20 uppercase letters/digits.');
  process.exit(1);
}

(async () => {
  console.log(`\n─── Seed test creator ───`);
  console.log(`  email: ${email}`);
  console.log(`  code:  ${code}`);

  let uid;
  try {
    uid = (await auth.getUserByEmail(email)).uid;
    console.log(`  → user uid: ${uid}`);
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      console.error(
        `\n✗ No Firebase user for ${email}. They need to sign in to MomRise once first.\n`,
      );
      process.exit(1);
    }
    throw err;
  }

  if (!name) {
    try {
      name = (await auth.getUser(uid)).displayName || email.split('@')[0];
    } catch {
      name = email.split('@')[0];
    }
  }

  // Idempotency on user_ref. If a creator already exists for this user,
  // update its code + onboarded flag instead of creating a duplicate.
  const userRef = db.doc(`users/${uid}`);
  const existing = await db
    .collection('creators')
    .where('user_ref', '==', userRef)
    .limit(1)
    .get();

  // Uniqueness on the code. If another creator already owns this code,
  // bail loudly — we don't want to silently steal it.
  const codeClash = await db
    .collection('creators')
    .where('code', '==', code)
    .limit(1)
    .get();
  if (
    !codeClash.empty &&
    (!existing.docs.length || codeClash.docs[0].id !== existing.docs[0].id)
  ) {
    console.error(
      `\n✗ Code "${code}" is already taken by another creator (${codeClash.docs[0].id}). Pick another.\n`,
    );
    process.exit(1);
  }

  const baseFields = {
    name,
    code,
    user_ref: userRef,
    is_active: true,
    bio: '',
    niche: '',
    avatar_url: '',
    follower_count: 0,
    subscriber_count: 0,
    lifetime_payout_cents: 0,
    theme_primary: '#52A097',
    // The whole point of this seed script: skip Stripe Connect for
    // sandbox testing so the webhook actually creates creator_earnings
    // rows instead of logging "not onboarded" and bailing.
    stripe_connect_onboarded: true,
    test_creator: true,
    code_set_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (!existing.empty) {
    const docRef = existing.docs[0].ref;
    await docRef.update({
      code,
      stripe_connect_onboarded: true,
      test_creator: true,
      code_set_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`\n✓ Updated existing creator ${docRef.id} → code ${code}\n`);
  } else {
    const docRef = db.collection('creators').doc();
    await docRef.set({
      ...baseFields,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`\n✓ Created creator ${docRef.id} for ${email} → code ${code}\n`);
  }

  console.log('Test by:');
  console.log(`  1. In the MomRise iOS app, Settings → Add Creator Code → enter ${code}`);
  console.log('  2. Confirm via Firestore: users/{uid}.active_creator_code = "' + code + '"');
  console.log('  3. Subscribe via sandbox → check creator_earnings collection');
  console.log('');
  process.exit(0);
})();
