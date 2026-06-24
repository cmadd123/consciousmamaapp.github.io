// Read-only: dump all creator_earnings rows for VESEL67 + the creator doc.
// Usage:  node admin/check-vesel67-earnings.js
//
// No mutations. Safe to run repeatedly.

const admin = require('firebase-admin');
const path = require('path');

const sa = require(path.join(__dirname, 'service-account.json'));
admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();

(async () => {
  const code = 'VESEL67';

  const creatorSnap = await db.collection('creators').where('code', '==', code).limit(1).get();
  if (creatorSnap.empty) {
    console.error(`No creator found with code ${code}`);
    process.exit(1);
  }
  const creatorDoc = creatorSnap.docs[0];
  const creator = creatorDoc.data();
  console.log('Creator:', creatorDoc.id);
  console.log('  raw fields: ', Object.keys(creator).sort().join(', '));
  console.log('  code:                       ', creator.code);
  console.log('  display_name:               ', creator.display_name || creator.name);
  console.log('  email:                      ', creator.email);
  console.log('  rev_share:                  ', creator.rev_share || '(default)');
  console.log('  stripe_connect_account_id:  ', creator.stripe_connect_account_id);
  console.log('  stripe_connect_onboarded:   ', creator.stripe_connect_onboarded);
  console.log('  stripe_connect_payouts_ok:  ', creator.stripe_connect_payouts_enabled);
  console.log('  lifetime_payout_cents:      ', creator.lifetime_payout_cents || 0);
  console.log('  last_payout_at:             ', creator.last_payout_at?.toDate?.()?.toISOString() || '(never)');
  console.log('  last_payout_cents:          ', creator.last_payout_cents || 0);
  console.log('');

  // No composite index on (creator_code, created_at desc) — query without
  // orderBy and sort client-side. We expect only a handful of rows for
  // this creator.
  const earningsSnap = await db.collection('creator_earnings')
    .where('creator_code', '==', code)
    .get();
  const earningDocs = earningsSnap.docs.slice().sort((a, b) => {
    const am = a.data().created_at?.toMillis?.() || 0;
    const bm = b.data().created_at?.toMillis?.() || 0;
    return bm - am;
  });

  if (earningsSnap.empty) {
    console.log('No earnings rows found for this creator.');
    process.exit(0);
  }

  let pendingTotal = 0;
  let paidTotal = 0;
  console.log(`Earnings rows: ${earningsSnap.size}`);
  console.log('');
  for (const doc of earningDocs) {
    const d = doc.data();
    console.log('  ' + doc.id);
    console.log('    kind:          ', d.kind);
    console.log('    source:        ', d.source || (d.invoice_id ? 'stripe' : '?'));
    console.log('    gross_cents:   ', d.gross_cents);
    console.log('    creator_cents: ', d.creator_cents);
    console.log('    rev_share:     ', d.rev_share);
    console.log('    environment:   ', d.environment);
    console.log('    payout_status: ', d.payout_status);
    console.log('    invoice_id:    ', d.invoice_id);
    console.log('    transaction_id:', d.transaction_id);
    console.log('    created_at:    ', d.created_at?.toDate?.()?.toISOString());
    console.log('    payout_id:     ', d.payout_id || '(unpaid)');
    console.log('    paid_at:       ', d.paid_at?.toDate?.()?.toISOString() || '(unpaid)');
    if (d.payout_status === 'pending') pendingTotal += d.creator_cents;
    if (d.payout_status === 'paid') paidTotal += d.creator_cents;
    console.log('');
  }

  console.log('--- Totals ---');
  console.log('  Pending creator_cents: ', pendingTotal, `($${(pendingTotal / 100).toFixed(2)})`);
  console.log('  Paid creator_cents:    ', paidTotal, `($${(paidTotal / 100).toFixed(2)})`);
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
