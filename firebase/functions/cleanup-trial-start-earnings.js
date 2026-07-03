// One-off: removes duplicate creator_earnings rows created by the
// pre-fix Apple IAP handler at trial-start.
//
// Bug context (2026-06-09):
//   The Apple IAP handler used to log a $X earning on SUBSCRIBED with
//   subtype INITIAL_BUY (trial start, no money exchanged), then a
//   second $X earning on DID_RENEW (trial conversion, real money).
//   Because Apple uses different transactionIds across the two events,
//   the transaction_id-based idempotency check didn't catch the
//   duplicate. Result: every creator-attributed trial-converting user
//   accidentally credited 2x.
//
// What this script does:
//   1. Queries creator_earnings for the duplicate signature:
//      apple_notification_type == "SUBSCRIBED" AND
//      apple_subtype == "INITIAL_BUY"
//   2. Verifies each match is a PROVABLE duplicate: a sibling DID_RENEW
//      earning must exist for the same original_transaction_id. The
//      signature alone also matches real immediate-charge purchases
//      (no trial), which must never be deleted. Unproven rows are
//      listed for manual review and always kept.
//   3. With --apply, DELETES the proven duplicates. Otherwise dry-run.
//
// Safe to run multiple times — once the trial-start rows are gone,
// subsequent runs find zero matches.
//
// Usage:
//   node cleanup-trial-start-earnings.js <service-account.json>           (dry run)
//   node cleanup-trial-start-earnings.js <service-account.json> --apply  (deletes)

const admin = require("firebase-admin");
const path = require("path");

const KEY_PATH = process.argv[2];
const APPLY = process.argv.includes("--apply");

if (!KEY_PATH || KEY_PATH.startsWith("--")) {
  console.error(
    "Usage: node cleanup-trial-start-earnings.js <service-account.json> [--apply]"
  );
  process.exit(1);
}

const serviceAccount = require(path.resolve(KEY_PATH));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

async function main() {
  console.log(
    `Mode: ${APPLY ? "APPLY (rows will be deleted)" : "DRY RUN (no writes)"}`
  );
  console.log();

  // Query the duplicate signature. Both fields are simple equality so
  // no composite index needed.
  const snap = await db
    .collection("creator_earnings")
    .where("apple_notification_type", "==", "SUBSCRIBED")
    .where("apple_subtype", "==", "INITIAL_BUY")
    .get();

  console.log(`Found ${snap.size} trial-start-signature earning rows.`);
  if (snap.empty) {
    console.log("Nothing to clean up. Exiting.");
    process.exit(0);
  }

  // CRITICAL GUARD: the SUBSCRIBED/INITIAL_BUY signature alone also
  // matches REAL immediate-charge purchases (no trial — e.g. an intro
  // offer already consumed), where the initial-buy row is the ONLY
  // record of real money. Deleting those rows deletes real earnings.
  // A row is a provable duplicate ONLY if its trial actually converted
  // — i.e. a sibling DID_RENEW earning exists for the same
  // original_transaction_id to carry the real credit. Rows without a
  // sibling are listed for manual review and never deleted.
  const dupDocs = [];
  const unproven = [];
  for (const doc of snap.docs) {
    const d = doc.data();
    const otid = d.original_transaction_id;
    if (!otid) {
      unproven.push({ doc, reason: "no original_transaction_id" });
      continue;
    }
    const sibling = await db
      .collection("creator_earnings")
      .where("original_transaction_id", "==", otid)
      .where("apple_notification_type", "==", "DID_RENEW")
      .limit(1)
      .get();
    if (sibling.empty) {
      unproven.push({ doc, reason: "no DID_RENEW sibling (real charge, or trial not yet converted)" });
    } else {
      dupDocs.push(doc);
    }
  }

  if (unproven.length > 0) {
    console.log();
    console.log(`⚠ KEEPING ${unproven.length} row(s) with no conversion sibling — NOT deleting:`);
    for (const { doc, reason } of unproven) {
      const d = doc.data();
      console.log(
        `  ${doc.id}  ${d.creator_code}  $${((d.creator_cents || 0) / 100).toFixed(2)}  tx=${d.transaction_id}  — ${reason}`
      );
    }
    console.log("  Review these manually: real immediate charges must stay; phantom");
    console.log("  never-converted trials should be removed by hand if confirmed.");
  }

  console.log();
  console.log(`${dupDocs.length} row(s) are provable duplicates (conversion sibling exists).`);
  if (dupDocs.length === 0) {
    console.log("Nothing safe to delete automatically. Exiting.");
    process.exit(0);
  }

  // Group by creator for the summary, also dump details
  const byCreator = new Map();
  let totalCents = 0;
  for (const doc of dupDocs) {
    const d = doc.data();
    const cents = d.creator_cents || 0;
    totalCents += cents;
    const code = d.creator_code || "(no code)";
    const entry = byCreator.get(code) || { count: 0, cents: 0, rows: [] };
    entry.count += 1;
    entry.cents += cents;
    entry.rows.push({
      doc_id: doc.id,
      cents,
      transaction_id: d.transaction_id,
      original_transaction_id: d.original_transaction_id,
      created_at: d.created_at?.toDate?.().toISOString?.() || "(no ts)",
      environment: d.environment,
      payout_status: d.payout_status,
    });
    byCreator.set(code, entry);
  }

  console.log();
  console.log("Per-creator breakdown of duplicates:");
  for (const [code, entry] of byCreator) {
    const dollars = (entry.cents / 100).toFixed(2);
    console.log(`  ${code}: ${entry.count} rows, $${dollars} duplicate credit`);
  }
  console.log();
  console.log(
    `Total duplicate credit to remove: $${(totalCents / 100).toFixed(2)}`
  );
  console.log();

  // Safety: warn on rows already in 'paid' status — those represent
  // money that already moved. Refuse to delete those without explicit
  // override (we'd need a clawback row instead).
  const paidRows = dupDocs.filter(
    (d) => d.data().payout_status === "paid"
  );
  if (paidRows.length > 0) {
    console.error(
      `⚠ ABORT: ${paidRows.length} duplicate rows are already in payout_status="paid".`
    );
    console.error(
      "  Money has already moved. Deleting these rows would corrupt the ledger."
    );
    console.error(
      "  Create clawback rows instead, or contact Stripe for refund support."
    );
    process.exit(2);
  }

  if (!APPLY) {
    console.log("Dry run complete. Re-run with --apply to delete these rows.");
    process.exit(0);
  }

  console.log("Deleting in batches of 400 (Firestore batch limit is 500)...");
  const docs = dupDocs;
  let deleted = 0;
  for (let i = 0; i < docs.length; i += 400) {
    const batch = db.batch();
    const slice = docs.slice(i, i + 400);
    for (const doc of slice) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += slice.length;
    console.log(`  deleted ${deleted}/${docs.length}`);
  }
  console.log();
  console.log(`✓ Deleted ${deleted} duplicate trial-start earning rows.`);
  console.log(`  Total credit removed: $${(totalCents / 100).toFixed(2)}`);
  console.log();
  console.log(
    "Creator dashboards will recalculate on next page load (sums on read)."
  );
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
