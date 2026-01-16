const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Make sure we initialize admin only once

exports.sendUserNotification = functions.https.onCall(async (data, context) => {
  const token = data.token;
  const title = data.title || "Reminder";
  const body = data.body || "Remember to plan your meal today in a good way!";

  if (!token) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "FCM token is required",
    );
  }

  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
    });

    // ✅ Always return a string
    return "Notification sent successfully";
  } catch (error) {
    console.error("Error sending notification:", error);

    // ✅ Return error as a string (not object)
    return `Error: ${error.message || "Unknown error"}`;
  }
});
