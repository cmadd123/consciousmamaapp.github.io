const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { ChatAnthropic } = require("@langchain/anthropic");
const { HumanMessage } = require("@langchain/core/messages");
const axios = require("axios").default;

admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
  await firestore.collection("users").doc(user.uid).delete();
});

/**
 * Scan a cookbook page image and extract recipe using Claude
 * Expects: { imageBase64: string } or { imageUrl: string }
 * Returns: { success: boolean, recipe: { name, prepTime, cookTime, ingredients[], instructions[] } }
 */
exports.scanCookbookWithClaude = functions
  .runWith({ timeoutSeconds: 120, memory: "512MB" })
  .https.onRequest(async (req, res) => {
    // Handle CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    try {
      const data = req.body.data || req.body;
      let imageBase64 = data.imageBase64;
      const imageUrl = data.imageUrl;

      // If we have a URL, fetch the image and convert to base64
      if (imageUrl && !imageBase64) {
        try {
          const response = await axios.get(imageUrl, { responseType: "arraybuffer" });
          imageBase64 = Buffer.from(response.data).toString("base64");
        } catch (err) {
          console.error("Failed to fetch image from URL:", err.message);
          res.status(400).json({ result: { success: false, error: "Could not fetch image from URL" } });
          return;
        }
      }

      if (!imageBase64) {
        res.status(400).json({ result: { success: false, error: "No image provided" } });
        return;
      }

      // Initialize Claude
      const model = new ChatAnthropic({
        model: "claude-sonnet-4-20250514",
        maxTokens: 2048,
        anthropicApiKey: process.env.ANTHROPIC_API_KEY || functions.config().anthropic?.api_key,
      });

      const prompt = `Analyze this cookbook/recipe page image and extract the recipe information.

IMPORTANT: Return ONLY a valid JSON object. No markdown, no code blocks, no explanation - just the raw JSON.

Extract these fields:
{
  "name": "Recipe name exactly as shown",
  "prepTime": number in minutes (0 if not specified),
  "cookTime": number in minutes (0 if not specified),
  "ingredients": ["ingredient 1 with quantity", "ingredient 2 with quantity"],
  "instructions": ["Step 1 complete instruction", "Step 2 complete instruction"],
  "servings": number (4 if not specified)
}

If the image is unclear or doesn't contain a recipe, return:
{"error": "description of the problem"}`;

      const message = new HumanMessage({
        content: [
          {
            type: "image_url",
            image_url: {
              url: `data:image/jpeg;base64,${imageBase64}`,
            },
          },
          {
            type: "text",
            text: prompt,
          },
        ],
      });

      const response = await model.invoke([message]);
      let responseText = response.content;

      // Clean up response - remove markdown code blocks if present
      if (typeof responseText === "string") {
        responseText = responseText.trim();
        if (responseText.startsWith("```json")) {
          responseText = responseText.substring(7);
        } else if (responseText.startsWith("```")) {
          responseText = responseText.substring(3);
        }
        if (responseText.endsWith("```")) {
          responseText = responseText.substring(0, responseText.length - 3);
        }
        responseText = responseText.trim();
      }

      const recipe = JSON.parse(responseText);

      if (recipe.error) {
        res.status(200).json({ result: { success: false, error: recipe.error } });
        return;
      }

      res.status(200).json({ result: { success: true, recipe } });
    } catch (error) {
      console.error("Error scanning cookbook:", error);
      res.status(500).json({ result: { success: false, error: error.message || "Failed to extract recipe" } });
    }
  });
