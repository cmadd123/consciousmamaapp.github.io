const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

exports.processReminders = functions.pubsub
  .schedule("every 1 minutes")
  .timeZone("Africa/Cairo") // adjust your timezone
  .onRun(async () => {
    const now = new Date();
    const remindersRef = admin.firestore().collection("reminders");

    // Query reminders that are due and not sent
    const snapshot = await remindersRef
      .where("time", "<=", now)
      .where("sent", "==", false)
      .get();

    if (snapshot.empty) {
      console.log("No reminders to send");
      return null;
    }

    console.log(
      "Reminders to send:",
      snapshot.docs.map((doc) => doc.id),
    );

    // Send push notifications for each reminder
    const jobs = snapshot.docs.map(async (doc) => {
      const reminder = doc.data();

      if (!reminder.token) {
        console.warn(`Reminder ${doc.id} has no token`);
        return;
      }

      const payload = {
        notification: {
          title: "Meal Planner 🍴", // default title
          body: "Don’t forget to plan your meals today!", // default body
        },
        token: reminder.token,
      };

      try {
        await admin.messaging().send(payload); // send push notification
        await doc.ref.update({ sent: true }); // mark as sent
        console.log(`Reminder ${doc.id} sent ✅`);
      } catch (error) {
        console.error(`Error sending reminder ${doc.id}:`, error);
      }
    });

    await Promise.all(jobs);

    return null;
  });
