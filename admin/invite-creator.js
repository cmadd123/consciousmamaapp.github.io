#!/usr/bin/env node
/**
 * MomRise creator invitation script (no application required).
 *
 * Use this when you're proactively recruiting a specific influencer — you
 * already know who they are, you don't need them to fill out the /apply/
 * form. Creates the creator doc directly and prints an invite email.
 *
 * USAGE
 *   node invite-creator.js <email> [--name "First Last"] [--uid <uid>]
 *
 * EXAMPLES
 *   node invite-creator.js haley@example.com --name "Haley Maddox"
 *   node invite-creator.js haley@example.com --uid cm1Abc…
 *
 * SETUP
 *   Same as approve-creator.js — needs admin/service-account.json and
 *   `npm install` in this directory.
 */

const admin = require('firebase-admin');
const readline = require('readline');
const path = require('path');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'service-account.json');
try {
  admin.initializeApp({
    credential: admin.credential.cert(require(SERVICE_ACCOUNT_PATH)),
  });
} catch (err) {
  console.error('\n✗ Could not load service-account.json from', SERVICE_ACCOUNT_PATH);
  console.error('  See admin/README.md for setup.\n');
  process.exit(1);
}
const db = admin.firestore();
const auth = admin.auth();

// ── Args ──────────────────────────────────────────────
const args = process.argv.slice(2);
const email = args.find(a => !a.startsWith('--'));
const flag = (name) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 ? args[i + 1] : null;
};
let name = flag('name');
const flagUid = flag('uid');

if (!email) {
  console.error('\nUsage: node invite-creator.js <email> [--name "First Last"] [--uid <uid>]\n');
  process.exit(1);
}

function prompt(q) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(r => rl.question(q, ans => { rl.close(); r(ans.trim()); }));
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
    return (await auth.getUserByEmail(email)).uid;
  } catch (err) {
    if (err.code === 'auth/user-not-found') return null;
    throw err;
  }
}

function inviteEmail(name, code) {
  const first = (name || '').split(' ')[0] || 'there';
  return `
Subject: ${first}, you're invited to the MomRise creator program

Hi ${first},

I'd love to have you in our creator program. It's just getting off the ground and I want to build it with a handful of moms whose work I already love — you're on that list.

Here's how it works: you earn 50% of every MomRise subscription from anyone who joins with your personal code. Not a one-time referral bonus — for as long as they stay subscribed.

Your code is: ${code}

To get started:

1. Sign in at https://momrise.app/creator/ with the Google or Apple account you use for MomRise. Your dashboard loads automatically.

2. Connect your bank through Stripe (2-3 minutes). This is how we pay you your 50% share.

3. Start sharing your code — in a post, a story, a newsletter, wherever.

Payouts run on the 10th of each month, minimum $25 (each earning is held 45 days first — we pay you when Apple pays us). Everything's in your dashboard — follower count, earnings, which content is landing.

Any questions, just reply. I'm thrilled to have you.

— Collin
MomRise
`.trim();
}

// ── Main ──────────────────────────────────────────────
(async () => {
  console.log(`\n─── Invite creator ───`);
  console.log(`  Email:  ${email}`);

  // Resolve user UID
  let uid = flagUid;
  if (!uid) {
    console.log(`\nLooking up Firebase user by email…`);
    uid = await findUserByEmail(email);
    if (uid) {
      console.log(`  → found uid ${uid}`);
    } else {
      console.log(`  → no Firebase user with that email.`);
      console.log(`\nThe invitee needs to sign up in the MomRise app first (free, no subscription), so we have a user doc to link to.`);
      console.log(`Once they've signed up, re-run with: node invite-creator.js ${email} --uid <their-uid>`);
      process.exit(0);
    }
  }

  // Verify + fetch their name if we can
  try {
    const userRec = await auth.getUser(uid);
    if (!name) name = userRec.displayName || '';
    console.log(`  → user: ${userRec.email || userRec.uid}${name ? `  (${name})` : ''}`);
  } catch (err) {
    console.error(`✗ Could not verify uid ${uid}: ${err.message}`);
    process.exit(1);
  }

  if (!name) {
    name = await prompt('  Creator display name: ');
    if (!name) { console.log('Cancelled (need a name).\n'); process.exit(0); }
  }

  // Check no existing creator doc for this user
  const existing = await db.collection('creators')
    .where('user_ref', '==', db.doc(`users/${uid}`))
    .limit(1)
    .get();
  if (!existing.empty) {
    const code = existing.docs[0].data().code || '(no code)';
    console.log(`\n! This user already has a creator doc (code: ${code}). Not overwriting.`);
    console.log(`  If they need a fresh start, archive or edit the existing creators/${existing.docs[0].id} doc first.\n`);
    process.exit(0);
  }

  const code = await generateUniqueCode(name);
  console.log(`Generated unique code: ${code}`);

  console.log('\nAbout to create creators/ doc:');
  console.log(`  name:       ${name}`);
  console.log(`  code:       ${code}`);
  console.log(`  user_ref:   users/${uid}`);
  console.log(`  is_active:  true`);
  const yn = await prompt('\nProceed? [y/N] ');
  if (yn.toLowerCase() !== 'y') { console.log('Cancelled.\n'); process.exit(0); }

  const creatorRef = db.collection('creators').doc();
  await creatorRef.set({
    name,
    code,
    user_ref: db.doc(`users/${uid}`),
    is_active: true,
    bio: '',
    niche: '',
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
    invited_directly: true,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`\n✓ Creator provisioned as creators/${creatorRef.id} with code ${code}.\n`);
  console.log('─── Invite email (paste into your mail client) ───\n');
  console.log(inviteEmail(name, code));
  console.log('');
})().catch(err => {
  console.error('\n✗ Error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
