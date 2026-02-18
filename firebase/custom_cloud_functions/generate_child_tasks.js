const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const moment = require("moment-timezone");

let _openai;
function getOpenAI() {
  if (!_openai) {
    _openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY || functions.config().openai?.key,
    });
  }
  return _openai;
}
const ASSISTANT_ID = "asst_Zrdo4Vh9j6BeaRALEXyqPZMZ";

const db = admin.firestore();

exports.generateChildTasks = functions.https.onCall(async (data, context) => {
  try {
    console.log("Received request:", data);

    const {
      challengeDescription,
      childBirthDate,
      currentDate,
      parentId,
      childId,
      frequency,
      preferredTime,
      timezone,
    } = data;

    if (
      !challengeDescription ||
      !childBirthDate ||
      !currentDate ||
      !parentId ||
      !childId ||
      !frequency ||
      !preferredTime ||
      !timezone
    ) {
      console.warn("Missing required fields", data);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields",
      );
    }

    console.log("Creating a thread with OpenAI Assistant");
    const thread = await getOpenAI().beta.threads.create();
    console.log("Thread created:", thread.id);

    // Force assistant to reply ONLY with JSON schema we want
    await getOpenAI().beta.threads.messages.create(thread.id, {
      role: "user",
      content: `Reply ONLY with valid JSON. 
Do not include explanations, markdown, or extra fields.

Format:
{
  "programe_title": "string",
  "programe_description": "string",
  "tasks": [
    {"title": "string", "description": "string", "duration": number}
  ]
}

Challenge Description: ${challengeDescription}
Child's Birthdate: ${childBirthDate}
Current Date: ${currentDate}`,
    });
    console.log("Message sent to assistant");

    const run = await getOpenAI().beta.threads.runs.create(thread.id, {
      assistant_id: ASSISTANT_ID,
    });
    console.log("Assistant run started:", run.id);

    let runStatus;
    do {
      runStatus = await getOpenAI().beta.threads.runs.retrieve(thread.id, run.id);
      console.log("Run status:", runStatus.status);
      await new Promise((resolve) => setTimeout(resolve, 2000));
    } while (runStatus.status !== "completed");

    console.log("Run completed. Fetching response messages.");
    const messages = await getOpenAI().beta.threads.messages.list(thread.id);
    const responseMessage = messages.data.find(
      (msg) => msg.role === "assistant",
    );

    let responseData = null;
    if (
      responseMessage &&
      responseMessage.content &&
      responseMessage.content.length > 0
    ) {
      const textBlock = responseMessage.content.find((c) => c.type === "text");
      if (textBlock) {
        let rawText = textBlock.text.value;
        console.log("Assistant raw text:", rawText);

        // Clean JSON if wrapped in ```json ... ```
        rawText = rawText.replace(/```json|```/g, "").trim();

        try {
          responseData = JSON.parse(rawText);
        } catch (e) {
          console.error("JSON parse error. Raw text was:", rawText);
          throw new functions.https.HttpsError(
            "internal",
            "Assistant did not return valid JSON",
          );
        }
      }
    }

    if (!responseData) {
      console.error("Invalid response from OpenAI");
      throw new functions.https.HttpsError(
        "internal",
        "Invalid response from OpenAI",
      );
    }

    // ✅ Validate required fields
    if (
      !responseData.programe_title ||
      !responseData.programe_description ||
      !Array.isArray(responseData.tasks)
    ) {
      console.error(
        "Assistant response missing required fields:",
        responseData,
      );
      throw new functions.https.HttpsError(
        "internal",
        "Assistant response missing required fields",
      );
    }

    console.log("Parsed assistant response:", responseData);

    console.log("Determining start_date based on preferred time and timezone");
    let startDate = moment.tz(currentDate, "YYYY-MM-DD HH:mm:ss.SSS", timezone);
    const now = moment.tz(timezone);

    // Detect format of preferredTime
    let timeFormat =
      preferredTime.includes("AM") || preferredTime.includes("PM")
        ? "YYYY-MM-DD hh:mm A"
        : "YYYY-MM-DD HH:mm";
    const preferredStartTime = moment.tz(
      `${startDate.format("YYYY-MM-DD")} ${preferredTime}`,
      timeFormat,
      timezone,
    );

    // If the preferred time has already passed today, move startDate to tomorrow
    if (now.isAfter(preferredStartTime)) {
      startDate.add(1, "day");
    }

    console.log(`Final start_date: ${startDate.format("DD-MM-YYYY")}`);
    const firestoreStartDate = admin.firestore.Timestamp.fromDate(
      startDate.toDate(),
    );

    console.log("Creating program document in Firestore");
    const programRef = await db.collection("programs").add({
      title: responseData.programe_title,
      description: responseData.programe_description,
      created_at: admin.firestore.Timestamp.now(),
      created_by: db.collection("users").doc(parentId),
      start_date: firestoreStartDate,
      end_date: null,
      tasks: [],
    });
    console.log("Program created with ID:", programRef.id);

    const taskRefs = [];
    const taskDates = [];
    let taskDate = startDate.clone();
    let endDate = startDate.clone();

    for (const task of responseData.tasks) {
      console.log("Creating task:", task.title);

      const taskStartTime = moment
        .tz(
          `${taskDate.format("DD-MM-YYYY")} ${preferredTime}`,
          "DD-MM-YYYY HH:mm",
          timezone,
        )
        .toDate();

      const taskDateString = taskDate.format("DD-MM-YYYY");

      const taskRef = await db.collection("tasks").add({
        title: task.title,
        description: task.description,
        duration: task.duration,
        created_by: db.collection("users").doc(parentId),
        selected_child: db.collection("children").doc(childId), // ✅ fixed typo
        program_id: programRef,
        task_date: taskDateString,
        task_start_time: admin.firestore.Timestamp.fromDate(taskStartTime),
      });

      taskRefs.push(taskRef);
      taskDates.push(admin.firestore.Timestamp.fromDate(taskStartTime));
      console.log("Task created with ID:", taskRef.id);

      taskDate.add(frequency, "days");
      endDate = taskDate.clone(); // Update end date to last task date
    }

    const firestoreEndDate = admin.firestore.Timestamp.fromDate(
      endDate.toDate(),
    );

    await programRef.update({
      tasks: taskRefs,
      end_date: firestoreEndDate,
      task_dates: taskDates,
    });

    console.log("Program document updated with task references and end_date");

    return {
      message: "Program and tasks created successfully",
      programId: programRef.id,
    };
  } catch (error) {
    console.error("Error processing request:", error);
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Internal server error",
    );
  }
});
