// One-shot: wipe Apple-IAP test artifacts so the next sandbox run
// starts from a clean slate. Safe to re-run; idempotent.
//
// Deletes:
//   - creator_earnings where source == 'apple_iap'  (test earnings only;
//     leaves Stripe rows intact)
//   - pending_attributions                          (24h TTL test rows)
//   - apple_notifications_seen                      (idempotency markers;
//     deletion just allows reprocessing on the off-chance Apple resends)
//
// Usage:
//   node admin/cleanup_test_data.js
//
// Requires admin/service-account.json (gitignored).

const admin = require('firebase-admin');
const path = require('path');

const sa = require(path.join(__dirname, 'service-account.json'));
admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();

async function deleteCollection(collection, where) {
  let query = db.collection(collection);
  if (where) query = query.where(...where);
  const snap = await query.get();
  if (snap.empty) {
    console.log(`  ${collection}: 0 docs`);
    return 0;
  }
  const batch = db.batch();
  snap.docs.forEach((d) => batch.delete(d.ref));
  await batch.commit();
  console.log(`  ${collection}: deleted ${snap.size} doc(s)`);
  return snap.size;
}

(async () => {
  console.log('Cleaning test data…');
  const earnings = await deleteCollection(
    'creator_earnings',
    ['source', '==', 'apple_iap'],
  );
  const pending = await deleteCollection('pending_attributions');
  const seen = await deleteCollection('apple_notifications_seen');
  console.log(
    `Done. Removed ${earnings} earnings + ${pending} pending + ${seen} seen.`,
  );
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
