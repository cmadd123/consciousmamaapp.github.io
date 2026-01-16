const functions = require("firebase-functions");
const admin = require("firebase-admin");
// To avoid deployment errors, do not call admin.initializeApp() in your code

exports.scahdulNotification = functions.https.onCall(async (data, context) => {
  const token = data.token; // String
  const time = data.time; // Timestamp/String

  if (!token || !time) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "token and time are required",
    );
  }

  const scheduledTime = new Date(time);
  const now = new Date();

  if (scheduledTime <= now) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "time must be in the future",
    );
  }

  await admin.firestore().collection("reminders").add({
    token: token,
    time: scheduledTime,
    sent: false,
  });

  return "✅ Reminder scheduled";
});
