const admin = require('firebase-admin');
const serviceAccount = require('./parenting-plus-7szrif-firebase-adminsdk-vdzbt-55cddb51d2.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Get a test user ID - you'll need to replace this with an actual user ID
// Or we can list users and pick the first one
admin.auth().listUsers(1)
  .then(async (listUsersResult) => {
    if (listUsersResult.users.length === 0) {
      console.log('No users found');
      return;
    }

    const userId = listUsersResult.users[0].uid;
    console.log(`Calling cleanup for user: ${userId}`);

    // Call the Cloud Function
    const functions = admin.functions();
    const cleanupUnlabeledContent = functions.httpsCallable('custom_cloud_functions-cleanupUnlabeledContent');

    try {
      const result = await cleanupUnlabeledContent({});
      console.log('Cleanup result:', result.data);
    } catch (error) {
      console.error('Error calling cleanup:', error);
    }

    process.exit(0);
  })
  .catch((error) => {
    console.error('Error listing users:', error);
    process.exit(1);
  });
