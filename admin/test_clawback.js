// Simulate an Apple REFUND notification end-to-end without depending
// on Apple's UI (which no longer exposes a sandbox refund button) or
// their API (which has no public refund-issuance endpoint).
//
// Picks the most recent apple_iap earning row, writes a matching
// clawback row using the same logic as recordAppleRefundClawback in
// functions/apple_iap_functions.js, and confirms the result.
//
// Usage:
//   node admin/test_clawback.js                     # most recent earning
//   node admin/test_clawback.js <transactionId>     # specific transaction
//
// Safe: idempotent on (transaction_id, kind='clawback'). Re-running
// won't duplicate.

const admin = require('firebase-admin');
const path = require('path');

const sa = require(path.join(__dirname, 'service-account.json'));
admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();

(async () => {
  const txId = process.argv[2];

  let earningSnap;
  if (txId) {
    earningSnap = await db
      .collection('creator_earnings')
      .where('transaction_id', '==', txId)
      .where('kind', '==', 'earning')
      .limit(1)
      .get();
  } else {
    earningSnap = await db
      .collection('creator_earnings')
      .where('source', '==', 'apple_iap')
      .where('kind', '==', 'earning')
      .orderBy('created_at', 'desc')
      .limit(1)
      .get();
  }

  if (earningSnap.empty) {
    console.error('No apple_iap earning row found' + (txId ? ` for tx ${txId}` : ''));
    process.exit(1);
  }
  const earningDoc = earningSnap.docs[0];
  const earning = earningDoc.data();

  console.log('Found earning:');
  console.log('  tx_id:        ', earning.transaction_id);
  console.log('  creator_code: ', earning.creator_code);
  console.log('  gross_cents:  ', earning.gross_cents);
  console.log('  creator_cents:', earning.creator_cents);
  console.log('  rev_share:    ', earning.rev_share);
  console.log('  environment:  ', earning.environment || '(legacy: no env field)');

  const existing = await db
    .collection('creator_earnings')
    .where('transaction_id', '==', earning.transaction_id)
    .where('kind', '==', 'clawback')
    .limit(1)
    .get();
  if (!existing.empty) {
    console.log('\nClawback already exists for this transaction. Skipping.');
    console.log('  clawback id:', existing.docs[0].id);
    process.exit(0);
  }

  const clawback = {
    creator_ref: earning.creator_ref,
    creator_code: earning.creator_code,
    user_ref: earning.user_ref,
    transaction_id: earning.transaction_id,
    original_transaction_id: earning.original_transaction_id || null,
    product_id: earning.product_id || null,
    gross_cents: -earning.gross_cents,
    creator_cents: -earning.creator_cents,
    rev_share: earning.rev_share || 0.5,
    currency: earning.currency || 'usd',
    payout_status: 'pending',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    kind: 'clawback',
    source: 'apple_iap',
    source_earning_ref: earningDoc.ref,
    environment: earning.environment || 'Sandbox', // legacy default
    test_simulated: true, // mark so it's clear this didn't come from Apple
  };

  const ref = await db.collection('creator_earnings').add(clawback);
  console.log('\nClawback row written:');
  console.log('  id:           ', ref.id);
  console.log('  gross_cents:  ', clawback.gross_cents);
  console.log('  creator_cents:', clawback.creator_cents);
  console.log('  environment:  ', clawback.environment);
  console.log('\nDone. Net for creator after this clawback: $0.');
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
