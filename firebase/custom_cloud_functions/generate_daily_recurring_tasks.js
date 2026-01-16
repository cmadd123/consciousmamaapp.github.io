const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Use existing initialized app from index.js
const db = admin.firestore();

exports.generateDailyRecurringTasks = functions.pubsub
  .schedule("0 5 * * *") // Every day at 05:00 AM France time
  .timeZone("Europe/Paris")
  .onRun(async () => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    console.log(
      "🚀 Running recurring task generator for:",
      today.toISOString(),
    );

    try {
      const snapshot = await db
        .collection("event_and_task")
        .where("isrecurring", "==", true)
        .get();

      if (snapshot.empty) {
        console.log("⚠️ No recurring tasks found");
        return null;
      }

      for (const doc of snapshot.docs) {
        const task = doc.data();

        // Safely handle timestamps or strings
        const lastGenerated =
          task.lastGenerated instanceof admin.firestore.Timestamp
            ? task.lastGenerated.toDate()
            : task.lastGenerated
              ? new Date(task.lastGenerated)
              : null;

        const originalDate =
          task.date instanceof admin.firestore.Timestamp
            ? task.date.toDate()
            : task.date
              ? new Date(task.date)
              : null;

        if (!originalDate) {
          console.warn(`⚠️ Skipping ${doc.id}: invalid date`);
          continue;
        }

        if (!lastGenerated || lastGenerated < today) {
          // Preserve same hour/minute from original date
          const newDate = new Date();
          newDate.setHours(
            originalDate.getHours(),
            originalDate.getMinutes(),
            0,
            0,
          );

          await db.collection("event_and_task").add({
            name: task.name,
            description: task.description,
            date: newDate,
            is_completed: false,
            isrecurring: true,
            selected_child: task.selected_child,
            typ: task.typ,
            user_ref: task.user_ref,
            lastGenerated: today,
          });

          await doc.ref.update({ lastGenerated: today });
          console.log(`✅ New recurring task created from: ${doc.id}`);
        } else {
          console.log(`⏩ Skipped ${doc.id}: already generated today`);
        }
      }
    } catch (error) {
      console.error("🔥 Error generating recurring tasks:", error);
    }

    return null;
  });
