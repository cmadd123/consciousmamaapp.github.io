const admin = require('firebase-admin');
const serviceAccount = require('./firebase/service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function getMilestones() {
  const snapshot = await db.collection('Static_Milestones').get();

  const byAgeAndCategory = {};

  snapshot.forEach(doc => {
    const data = doc.data();
    const age = data.age || 'unknown';
    const category = data.act_goal || data.Category || 'unknown';

    if (!byAgeAndCategory[age]) {
      byAgeAndCategory[age] = {};
    }
    if (!byAgeAndCategory[age][category]) {
      byAgeAndCategory[age][category] = 0;
    }
    byAgeAndCategory[age][category]++;
  });

  console.log('Total documents:', snapshot.size);
  console.log('\nMilestones by Age and Category:');

  const ages = Object.keys(byAgeAndCategory).sort((a, b) => parseFloat(a) - parseFloat(b));
  for (const age of ages) {
    console.log('\nAge ' + age + ':');
    for (const [cat, count] of Object.entries(byAgeAndCategory[age])) {
      console.log('  ' + cat + ': ' + count);
    }
  }
}

getMilestones().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
