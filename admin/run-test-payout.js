// Manual creator payout trigger — bypasses the 45-day holdback enforced by
// the scheduled runCreatorPayouts function. Use this for testing the
// end-to-end Stripe Connect transfer path before Apple has deposited the
// IAP revenue to the platform.
//
// IMPORTANT: This actually moves money. The platform balance must be able
// to cover the transfer. Live Stripe will refuse with InsufficientFunds
// if the platform hasn't been funded.
//
// Usage:
//   $env:STRIPE_SECRET_KEY = (Get-Content C:\temp\stripe_key.txt -Raw).Trim()
//   node admin/run-test-payout.js VESEL67            # dry-run (no transfer)
//   node admin/run-test-payout.js VESEL67 --commit   # execute
//
// Safe to dry-run repeatedly. The --commit path is idempotent at the
// payout_status level: once a row flips to 'paid', subsequent runs skip
// it.

const admin = require('firebase-admin');
const path = require('path');

const code = process.argv[2];
const commit = process.argv.includes('--commit');
if (!code) {
  console.error('Usage: node admin/run-test-payout.js <CREATOR_CODE> [--commit]');
  process.exit(1);
}

const stripeKey = (process.env.STRIPE_SECRET_KEY || '').trim();
if (commit && !stripeKey) {
  console.error('STRIPE_SECRET_KEY env var is required for --commit. Dry-run only without it.');
  process.exit(1);
}
if (commit && !stripeKey.startsWith('sk_')) {
  console.error('STRIPE_SECRET_KEY does not look like a Stripe secret key (sk_...). Aborting.');
  process.exit(1);
}

const sa = require(path.join(__dirname, 'service-account.json'));
admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const PAYOUT_MIN_CENTS = 2500; // matches stripe_functions.js threshold

(async () => {
  const creatorSnap = await db.collection('creators').where('code', '==', code).limit(1).get();
  if (creatorSnap.empty) {
    console.error(`No creator found with code ${code}`);
    process.exit(1);
  }
  const creatorDoc = creatorSnap.docs[0];
  const creator = creatorDoc.data();

  if (!creator.stripe_connect_onboarded || !creator.stripe_connect_account_id) {
    console.error(`Creator ${code} is not onboarded — Connect account missing or incomplete.`);
    process.exit(1);
  }
  if (!creator.stripe_connect_payouts_enabled) {
    console.error(`Creator ${code} has stripe_connect_payouts_enabled=false. Cannot transfer.`);
    process.exit(1);
  }

  const pendingSnap = await db.collection('creator_earnings')
    .where('creator_code', '==', code)
    .where('payout_status', '==', 'pending')
    .get();

  let total = 0;
  const docs = [];
  for (const doc of pendingSnap.docs) {
    const d = doc.data();
    if (d.environment === 'Sandbox') continue; // never pay sandbox
    docs.push(doc);
    total += d.creator_cents || 0;
  }

  console.log('--- Manual payout (holdback bypassed) ---');
  console.log('Creator:    ', code, '   doc:', creatorDoc.id);
  console.log('Connect acct:', creator.stripe_connect_account_id);
  console.log('Eligible rows:', docs.length, '   total cents:', total, `($${(total / 100).toFixed(2)})`);
  if (total < PAYOUT_MIN_CENTS) {
    console.warn(`Total below $${PAYOUT_MIN_CENTS / 100} threshold. Scheduled runner would skip this; manual run will still proceed if --commit is set.`);
  }
  if (total <= 0) {
    console.error('Nothing to pay. Exiting.');
    process.exit(1);
  }

  if (!commit) {
    console.log('\nDry-run only. Re-run with --commit to execute the transfer.');
    process.exit(0);
  }

  const stripe = require(path.join(__dirname, 'node_modules/stripe'))(stripeKey);
  console.log('\nExecuting Stripe transfer…');
  const transfer = await stripe.transfers.create({
    amount: total,
    currency: 'usd',
    destination: creator.stripe_connect_account_id,
    description: `MomRise creator payout (manual test) — ${code}`,
    metadata: {
      creator_code: code,
      creator_id: creatorDoc.id,
      source: 'admin/run-test-payout.js',
    },
  });
  console.log('Transfer created:', transfer.id);

  const paidAt = FieldValue.serverTimestamp();
  const batch = db.batch();
  for (const doc of docs) {
    batch.update(doc.ref, {
      payout_status: 'paid',
      payout_id: transfer.id,
      paid_at: paidAt,
    });
  }
  batch.update(creatorDoc.ref, {
    lifetime_payout_cents: FieldValue.increment(total),
    last_payout_at: paidAt,
    last_payout_cents: total,
  });
  await batch.commit();
  console.log('Ledger updated:', docs.length, 'rows marked paid.');
  process.exit(0);
})().catch((e) => {
  console.error('Payout failed:', e.message);
  if (e.raw) console.error('Stripe error:', JSON.stringify(e.raw, null, 2));
  process.exit(1);
});
