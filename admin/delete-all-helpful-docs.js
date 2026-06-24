// Delete every Helpful Docs entry: clears the Firestore app_content docs
// where content_type == 'pdf' AND deletes the underlying PDF in Cloud
// Storage. Dry-run by default. Use --commit to actually delete.
//
// Scoped to content_type == 'pdf' so any other future app_content (videos,
// articles, etc.) is left untouched.
//
// Usage:
//   node admin/delete-all-helpful-docs.js                # dry-run, lists what would be deleted
//   node admin/delete-all-helpful-docs.js --commit       # executes
//
// Idempotent: re-running on a clean collection is a no-op. Safe.

const admin = require('firebase-admin');
const path = require('path');

const commit = process.argv.includes('--commit');

const sa = require(path.join(__dirname, 'service-account.json'));
admin.initializeApp({
  credential: admin.credential.cert(sa),
  storageBucket: `${sa.project_id}.appspot.com`,
});
const db = admin.firestore();
const bucket = admin.storage().bucket();

(async () => {
  const snap = await db.collection('app_content')
    .where('content_type', '==', 'pdf')
    .get();

  if (snap.empty) {
    console.log('No Helpful Docs (content_type=="pdf") found. Nothing to delete.');
    process.exit(0);
  }

  console.log(`Found ${snap.size} Helpful Docs:`);
  console.log('');
  for (const doc of snap.docs) {
    const d = doc.data();
    console.log(`  ${doc.id}`);
    console.log(`    title:            ${d.title || '(no title)'}`);
    console.log(`    category:         ${d.category || '(none)'}`);
    console.log(`    is_published:     ${d.is_published === true}`);
    console.log(`    pdf_storage_path: ${d.pdf_storage_path || '(none)'}`);
    console.log(`    view_count:       ${d.view_count || 0}`);
    console.log('');
  }

  if (!commit) {
    console.log('Dry-run only. Re-run with --commit to actually delete.');
    process.exit(0);
  }

  console.log('Executing deletes…');
  let storageDeleted = 0;
  let storageMissing = 0;
  let firestoreDeleted = 0;
  for (const doc of snap.docs) {
    const d = doc.data();
    if (d.pdf_storage_path) {
      try {
        await bucket.file(d.pdf_storage_path).delete();
        storageDeleted++;
        console.log(`  ✓ Storage: ${d.pdf_storage_path}`);
      } catch (e) {
        if (e.code === 404) {
          storageMissing++;
          console.log(`  · Storage already gone: ${d.pdf_storage_path}`);
        } else {
          console.warn(`  ! Storage delete failed for ${d.pdf_storage_path}: ${e.message}`);
        }
      }
    }
    await doc.ref.delete();
    firestoreDeleted++;
    console.log(`  ✓ Firestore: app_content/${doc.id}`);
  }

  console.log('');
  console.log('Done.');
  console.log(`  Firestore docs deleted: ${firestoreDeleted}`);
  console.log(`  Storage files deleted:  ${storageDeleted}`);
  console.log(`  Storage already-gone:   ${storageMissing}`);
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
