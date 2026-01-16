const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function countRecipes() {
  console.log('Counting recipes in Firebase...\n');

  const mealsRef = db.collection('meal');
  const snapshot = await mealsRef.get();

  let curatedCount = 0;
  let userCount = 0;
  let totalCount = snapshot.docs.length;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.is_curated === true) {
      curatedCount++;
    } else {
      userCount++;
    }
  }

  console.log(`Total recipes: ${totalCount}`);
  console.log(`Curated (Pinterest imports): ${curatedCount}`);
  console.log(`User recipes: ${userCount}`);

  // List first 10 curated recipes
  console.log('\nFirst 10 curated recipes:');
  let count = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.is_curated === true && count < 10) {
      console.log(`  - ${data.recipe_name || data.recipeName}`);
      count++;
    }
  }

  process.exit(0);
}

countRecipes().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
