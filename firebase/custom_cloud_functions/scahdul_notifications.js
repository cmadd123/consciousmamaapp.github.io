const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.scahdulNotifications = functions.https.onCall(async (data, context) => {
  const token = data.token;
  const title = data.title || "Reminder";
  const body = data.body || "Remember to plan your meal today in a good way!";

  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
    });

    // ✅ Return a plain string only
    return "Notification sent successfully";
  } catch (error) {
    console.error("Error sending notification:", error);

    // ✅ Also return a plain string on error
    return `Error: ${error.message || "Unknown error"}`;
  }
});
