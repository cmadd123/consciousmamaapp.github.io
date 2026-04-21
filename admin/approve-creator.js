#!/usr/bin/env node
/**
 * MomRise creator-application approval script.
 *
 * USAGE
 *   node approve-creator.js                    # lists pending applications
 *   node approve-creator.js <applicationId>    # approves a specific application
 *   node approve-creator.js <applicationId> --uid <firebaseUid>
 *   node approve-creator.js <applicationId> --reject
 *
 * SETUP (one-time)
 *   1. Firebase Console → Project settings → Service accounts → Generate new
 *      private key. Save as admin/service-account.json (gitignored).
 *   2. cd admin && npm install
 *
 * WHAT IT DOES
 *   - Reads creator_applications/{id}
 *   - Resolves the user by the email they submitted with (or the --uid flag)
 *   - Generates a unique creator code from their name + 2 random digits
 *   - Writes creators/{autoId} with defaults + theme seeded to MomRise teal
 *   - Marks the application approved (or rejected) with a timestamp
 *   - Prints a welcome-email body to copy into your mail client
 */

const admin = require('firebase-admin');
const readline = require('readline');
const path = require('path');

// ── Init ──────────────────────────────────────────────
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

// ── Args ──────────────────────────────────────────────
const args = process.argv.slice(2);
const applicationId = args.find(a => !a.startsWith('--'));
const flagUid = (() => {
  const i = args.indexOf('--uid');
  return i >= 0 ? args[i + 1] : null;
})();
const isReject = args.includes('--reject');

// ── Helpers ───────────────────────────────────────────
async function listPending() {
  const snap = await db.collection('creator_applications')
    .where('status', '==', 'new')
    .orderBy('submitted_at', 'desc')
    .limit(25)
    .get();

  if (snap.empty) {
    console.log('\nNo pending applications.\n');
    return;
  }
  console.log(`\nPending applications (${snap.size}):\n`);
  for (const doc of snap.docs) {
    const d = doc.data();
    const at = d.submitted_at?.toDate?.().toISOString().slice(0, 16).replace('T', ' ') || '?';
    console.log(`  ${doc.id}`);
    console.log(`    ${d.name}  ·  ${d.email}`);
    console.log(`    ${d.primary_handle}  ·  ${d.audience_size}  ·  ${at}`);
    console.log('');
  }
  console.log('Approve:   node approve-creator.js <applicationId>');
  console.log('Reject:    node approve-creator.js <applicationId> --reject\n');
}

function prompt(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(resolve => rl.question(question, ans => { rl.close(); resolve(ans.trim()); }));
}

async function generateUniqueCode(baseName) {
  const clean = (baseName || 'CREATOR').replace(/[^A-Za-z]/g, '').toUpperCase();
  const stem = (clean.slice(0, 5) || 'MOM').padEnd(3, 'X');
  for (let attempt = 0; attempt < 25; attempt++) {
    const suffix = String(Math.floor(Math.random() * 90) + 10);
    const candidate = `${stem}${suffix}`;
    const existing = await db.collection('creators').where('code', '==', candidate).limit(1).get();
    if (existing.empty) return candidate;
  }
  throw new Error('Could not generate a unique code after 25 attempts');
}

async function findUserByEmail(email) {
  try {
    const user = await auth.getUserByEmail(email);
    return user.uid;
  } catch (err) {
    if (err.code === 'auth/user-not-found') return null;
    throw err;
  }
}

function welcomeEmail(name, code) {
  return `
Subject: Welcome to the MomRise creator program, ${name.split(' ')[0]}!

Hi ${name.split(' ')[0]},

You're in. Welcome to the MomRise creator program.

Your creator code: ${code}

Next steps:

1. Log in at https://momrise.app/creator/ with the same Google or Apple
   account you use for MomRise. Your dashboard will load automatically.

2. Connect your bank through Stripe (takes 2-3 minutes). This is how we
   pay you your 50% share.

3. Share your code — ${code} — with your community. Every follower who
   subscribes using this code earns you half their subscription for as
   long as they stay.

Payouts run on the 1st of every month, minimum $25. Full details in
your dashboard.

Questions? Just reply to this email.

— MomRise team
`.trim();
}

// ── Main ──────────────────────────────────────────────
(async () => {
  if (!applicationId) {
    await listPending();
    process.exit(0);
  }

  const appRef = db.collection('creator_applications').doc(applicationId);
  const appDoc = await appRef.get();
  if (!appDoc.exists) {
    console.error(`✗ Application ${applicationId} not found`);
    process.exit(1);
  }
  const appData = appDoc.data();

  console.log('\n─── Application ───');
  console.log(`  Name:         ${appData.name}`);
  console.log(`  Email:        ${appData.email}`);
  console.log(`  Handle:       ${appData.primary_handle}`);
  console.log(`  Audience:     ${appData.audience_size}`);
  console.log(`  Website:      ${appData.website || '(none)'}`);
  console.log(`  Community:    ${appData.audience_description}`);
  console.log(`  Pitch:        ${appData.pitch}`);
  console.log(`  Status:       ${appData.status}`);
  console.log('');

  if (appData.status !== 'new') {
    console.warn(`! Already processed (status=${appData.status}). Continue anyway?`);
    const yn = await prompt('  [y/N] ');
    if (yn.toLowerCase() !== 'y') { console.log('Cancelled.\n'); process.exit(0); }
  }

  if (isReject) {
    await appRef.update({
      status: 'rejected',
      rejected_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`✓ Marked ${applicationId} rejected.\n`);
    process.exit(0);
  }

  // Resolve user UID
  let uid = flagUid;
  if (!uid) {
    console.log(`Looking up user by submitted email (${appData.email})…`);
    uid = await findUserByEmail(appData.email);
    if (uid) {
      console.log(`  → found uid ${uid}`);
    } else {
      console.log(`  → no Firebase user with that email.`);
      const entered = await prompt('  Paste the UID manually (or blank to cancel): ');
      if (!entered) { console.log('Cancelled.\n'); process.exit(0); }
      uid = entered;
    }
  }

  // Verify UID resolves
  try {
    const userRec = await auth.getUser(uid);
    console.log(`  → user: ${userRec.email || userRec.uid}`);
  } catch (err) {
    console.error(`✗ Could not verify uid ${uid}: ${err.message}`);
    process.exit(1);
  }

  // Unique code
  const code = await generateUniqueCode(appData.name);
  console.log(`Generated unique code: ${code}`);

  // Confirm
  console.log('\nAbout to create creators/ doc:');
  console.log(`  name:       ${appData.name}`);
  console.log(`  code:       ${code}`);
  console.log(`  user_ref:   users/${uid}`);
  console.log(`  is_active:  true`);
  const yn = await prompt('\nProceed? [y/N] ');
  if (yn.toLowerCase() !== 'y') { console.log('Cancelled.\n'); process.exit(0); }

  // Create
  const creatorRef = db.collection('creators').doc();
  await creatorRef.set({
    name: appData.name,
    code,
    user_ref: db.doc(`users/${uid}`),
    is_active: true,
    bio: appData.audience_description || '',
    niche: appData.audience_description || '',
    avatar_url: '',
    follower_count: 0,
    subscriber_count: 0,
    lifetime_payout_cents: 0,
    theme_primary: '#52A097',
    theme_secondary: '#D7F2EB',
    theme_accent: '#EE8B60',
    theme_font: '',
    theme_font_url: '',
    stripe_connect_onboarded: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  await appRef.update({
    status: 'approved',
    approved_at: admin.firestore.FieldValue.serverTimestamp(),
    approved_creator_ref: creatorRef,
    assigned_code: code,
    assigned_uid: uid,
  });

  console.log(`\n✓ Creator provisioned as creators/${creatorRef.id} with code ${code}.`);
  console.log('✓ Application marked approved.\n');
  console.log('─── Welcome email (paste into your mail client) ───\n');
  console.log(welcomeEmail(appData.name, code));
  console.log('');
})().catch(err => {
  console.error('\n✗ Error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
