const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteTestRecipes() {
  console.log('Searching for test recipes containing "chicken dinner"...');

  const mealsRef = db.collection('meal');
  const snapshot = await mealsRef.get();

  let deletedCount = 0;
  const batch = db.batch();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const recipeName = (data.recipe_name || data.recipeName || '').toLowerCase();

    // Match "chicken dinner" test recipes
    if (recipeName.includes('chicken dinner') || recipeName.includes('test recipe')) {
      console.log(`Found test recipe: "${data.recipe_name || data.recipeName}" (${doc.id})`);
      batch.delete(doc.ref);
      deletedCount++;
    }
  }

  if (deletedCount > 0) {
    console.log(`\nDeleting ${deletedCount} test recipes...`);
    await batch.commit();
    console.log('Done!');
  } else {
    console.log('No test recipes found.');
  }

  process.exit(0);
}

deleteTestRecipes().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
