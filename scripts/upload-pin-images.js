// Uploads every rendered magazine pin (scripts/output/pins/{slug}.png)
// to Firebase Storage at pins/{slug}.png, then backfills the public URL
// onto the matching recipe doc in Firestore as magazine_pin_url.
//
// After running this, the pin generator at /admin/pin-generator.html
// will pass the magazine image to Pinterest instead of the source blog's
// hero image — Haley's pins use our branded design.
//
// Idempotent: re-running overwrites the Storage object + Firestore field.
//
// Usage: NODE_PATH=./admin/node_modules node scripts/upload-pin-images.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const pinsDir = path.join(repoRoot, 'scripts', 'output', 'pins');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(require(saPath)),
  storageBucket: 'parenting-plus-7szrif.appspot.com',
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

function kebab(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .slice(0, 60);
}

function slugFor(recipe, docId) {
  return `${kebab(recipe.recipe_name)}-${docId.slice(-6)}` || `recipe-${docId.slice(-6)}`;
}

(async () => {
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  console.log(`Found ${snap.size} curated recipes. Uploading pin images…\n`);

  let uploaded = 0;
  let missing = 0;
  let failed = 0;

  for (const doc of snap.docs) {
    const recipe = doc.data();
    const slug = slugFor(recipe, doc.id);
    const localPath = path.join(pinsDir, `${slug}.png`);

    if (!fs.existsSync(localPath)) {
      console.log(`  · Skip ${slug}.png (not rendered yet)`);
      missing++;
      continue;
    }

    try {
      const remoteFile = bucket.file(`pins/${slug}.png`);
      await bucket.upload(localPath, {
        destination: `pins/${slug}.png`,
        metadata: {
          contentType: 'image/png',
          cacheControl: 'public, max-age=31536000, immutable',
        },
      });
      // Public URL via the standard Firebase Storage download token —
      // makeUploadable + the public-read rule above means Pinterest can
      // fetch it without auth.
      await remoteFile.makePublic();
      const url = `https://storage.googleapis.com/${bucket.name}/pins/${slug}.png`;

      await doc.ref.update({ magazine_pin_url: url });
      console.log(`  ✓ ${slug}.png`);
      uploaded++;
    } catch (e) {
      console.log(`  ! ${slug}.png — ${e.message}`);
      failed++;
    }
  }

  console.log(`\nDone. Uploaded ${uploaded}, missing ${missing}, failed ${failed}.`);
  console.log(`Pin generator now uses magazine_pin_url with image_url as fallback.`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
