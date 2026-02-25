const functions = require("firebase-functions");
const https = require("https");
const http = require("http");
const OpenAI = require("openai");

let _openai;
function getOpenAI() {
  if (!_openai) {
    _openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY || functions.config().openai?.key,
    });
  }
  return _openai;
}

/**
 * Cloud Function to extract recipe details from a URL.
 * Uses JSON-LD structured data that most recipe sites include.
 * v4 - HTTP trigger (onRequest) to bypass App Check completely
 */
exports.extractRecipe = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    // Support both GET query param and POST body
    const url = req.body?.data?.url || req.body?.url || req.query?.url;
    const recipeText = req.body?.data?.text || req.body?.text;

    // AI text parsing mode - user pasted recipe text
    if (recipeText && recipeText.trim().length > 0) {
      console.log("AI text parsing mode, text length:", recipeText.length);
      const recipe = await parseRecipeWithAI(recipeText);
      if (recipe) {
        res.status(200).json({ result: { success: true, recipe: recipe } });
      } else {
        res.status(400).json({
          result: { success: false, error: "Could not parse recipe from the provided text. Try including the recipe name, ingredients, and instructions." }
        });
      }
      return;
    }

    if (!url) {
      res.status(400).json({
        result: { success: false, error: "Missing 'url' or 'text' in request" }
      });
      return;
    }

    console.log("Received URL:", url);

    // Handle Pinterest URLs - need to extract the actual recipe source URL
    let targetUrl = url;
    let isPinterestUrl = url.includes("pin.it") || url.includes("pinterest.com");

    if (isPinterestUrl) {
      console.log("Pinterest URL detected, resolving source...");
      const resolveResult = await resolvePinterestUrl(url);
      targetUrl = resolveResult.url;
      console.log("Resolved to:", targetUrl);

      // Check if we couldn't find an external source URL
      if (!resolveResult.foundExternalLink) {
        res.status(400).json({
          result: {
            success: false,
            error: "This Pinterest pin doesn't link to an external recipe website. " +
              "Try a pin that links to a recipe blog or cooking site."
          }
        });
        return;
      }
    }

    // Fetch the HTML from the URL
    const html = await fetchUrl(targetUrl);

    // Try to extract recipe from JSON-LD structured data
    const recipe = extractRecipeFromHtml(html, targetUrl);

    if (!recipe) {
      // Provide helpful error based on the source
      const errorMsg = isPinterestUrl
        ? "The linked website doesn't have recipe data we can import. This works best with recipe blogs that use structured data."
        : "Could not find recipe data on this page. Make sure the URL is a recipe page, not a general website.";

      res.status(404).json({
        result: { success: false, error: errorMsg }
      });
      return;
    }

    console.log("Successfully extracted recipe:", recipe.name);

    // Return in callable-compatible format
    res.status(200).json({
      result: {
        success: true,
        recipe: recipe
      }
    });
  } catch (error) {
    console.error("Error extracting recipe:", error);
    res.status(500).json({
      result: {
        success: false,
        error: error.message || "Failed to extract recipe"
      }
    });
  }
});

/**
 * Resolve Pinterest short URLs and extract the actual recipe source URL
 * Returns { url: string, foundExternalLink: boolean }
 */
async function resolvePinterestUrl(url) {
  // First, follow redirects to get to the pinterest.com/pin/... page
  const pinterestHtml = await fetchUrl(url);

  // Look for the source link in Pinterest page
  // Pinterest stores the source URL in various places:

  // 1. Look for "link" in JSON data
  const jsonDataMatch = pinterestHtml.match(/<script[^>]*id="__PWS_DATA__"[^>]*>([\s\S]*?)<\/script>/i) ||
                        pinterestHtml.match(/<script[^>]*data-relay-response="true"[^>]*>([\s\S]*?)<\/script>/i);

  if (jsonDataMatch) {
    try {
      const jsonData = JSON.parse(jsonDataMatch[1]);
      const sourceUrl = findSourceUrlInPinterestData(jsonData);
      if (sourceUrl && !sourceUrl.includes("pinterest.com")) {
        return { url: sourceUrl, foundExternalLink: true };
      }
    } catch (e) {
      console.log("Could not parse Pinterest JSON data:", e.message);
    }
  }

  // 2. Look for link attribute in the HTML
  const linkMatch = pinterestHtml.match(/\"link\"\s*:\s*\"(https?:[^\"]+)\"/i) ||
                    pinterestHtml.match(/data-pin-href=\"(https?:[^\"]+)\"/i) ||
                    pinterestHtml.match(/\"pinner\".*?\"link\"\s*:\s*\"(https?:[^\"]+)\"/i);

  if (linkMatch) {
    let sourceUrl = linkMatch[1].replace(/\\u002F/g, "/").replace(/\\/g, "");
    if (!sourceUrl.includes("pinterest.com")) {
      return { url: sourceUrl, foundExternalLink: true };
    }
  }

  // 3. Look for canonical or source URL patterns
  const sourcePatterns = [
    /\"sourceUrl\"\s*:\s*\"(https?:[^\"]+)\"/i,
    /\"richPinUrl\"\s*:\s*\"(https?:[^\"]+)\"/i,
    /\"attributionLink\"\s*:\s*\"(https?:[^\"]+)\"/i,
    /class="[^"]*source[^"]*"[^>]*href="(https?:[^"]+)"/i
  ];

  for (const pattern of sourcePatterns) {
    const match = pinterestHtml.match(pattern);
    if (match) {
      let sourceUrl = match[1].replace(/\\u002F/g, "/").replace(/\\/g, "");
      if (!sourceUrl.includes("pinterest.com")) {
        return { url: sourceUrl, foundExternalLink: true };
      }
    }
  }

  // If we couldn't find a source URL, return the original with flag indicating no external link found
  console.log("Could not find external source URL in Pinterest page");
  return { url: url, foundExternalLink: false };
}

/**
 * Recursively search Pinterest JSON data for source URL
 */
function findSourceUrlInPinterestData(obj, depth = 0) {
  if (depth > 10 || !obj) return null;

  if (typeof obj === "string") return null;

  // Look for common source URL fields
  const urlFields = ["link", "sourceUrl", "richPinUrl", "attributionLink"];
  for (const field of urlFields) {
    if (obj[field] && typeof obj[field] === "string" &&
        obj[field].startsWith("http") && !obj[field].includes("pinterest.com")) {
      return obj[field];
    }
  }

  // Recurse into objects and arrays
  if (Array.isArray(obj)) {
    for (const item of obj) {
      const result = findSourceUrlInPinterestData(item, depth + 1);
      if (result) return result;
    }
  } else if (typeof obj === "object") {
    for (const key of Object.keys(obj)) {
      const result = findSourceUrlInPinterestData(obj[key], depth + 1);
      if (result) return result;
    }
  }

  return null;
}

/**
 * Fetch URL content with redirect following
 */
function fetchUrl(url, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 5) {
      reject(new Error("Too many redirects"));
      return;
    }

    const protocol = url.startsWith("https") ? https : http;

    const request = protocol.get(url, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
      }
    }, (response) => {
      // Handle redirects
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        let redirectUrl = response.headers.location;
        // Handle relative URLs
        if (redirectUrl.startsWith("/")) {
          const urlObj = new URL(url);
          redirectUrl = `${urlObj.protocol}//${urlObj.host}${redirectUrl}`;
        }
        resolve(fetchUrl(redirectUrl, redirectCount + 1));
        return;
      }

      if (response.statusCode !== 200) {
        reject(new Error(`HTTP ${response.statusCode}`));
        return;
      }

      let data = "";
      response.on("data", (chunk) => {
        data += chunk;
      });
      response.on("end", () => {
        resolve(data);
      });
    });

    request.on("error", reject);
    request.setTimeout(30000, () => {
      request.destroy();
      reject(new Error("Request timeout"));
    });
  });
}

/**
 * Extract recipe data from HTML using JSON-LD structured data
 */
function extractRecipeFromHtml(html, sourceUrl) {
  // Try to find JSON-LD structured data (most recipe sites use this)
  const jsonLdMatches = html.match(/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi);

  if (jsonLdMatches) {
    for (const match of jsonLdMatches) {
      try {
        const jsonContent = match.replace(/<script[^>]*>|<\/script>/gi, "").trim();
        const data = JSON.parse(jsonContent);

        // Handle array of items
        const items = Array.isArray(data) ? data : [data];

        for (const item of items) {
          const recipe = findRecipeInJsonLd(item);
          if (recipe) {
            return normalizeRecipe(recipe, sourceUrl);
          }
        }
      } catch (e) {
        // Continue to next match
        continue;
      }
    }
  }

  // Fallback: Try to extract from meta tags and common patterns
  return extractFromMetaTags(html, sourceUrl);
}

/**
 * Find Recipe object in JSON-LD data (handles @graph and nested structures)
 */
function findRecipeInJsonLd(data) {
  if (!data) return null;

  // Direct recipe
  if (data["@type"] === "Recipe" ||
      (Array.isArray(data["@type"]) && data["@type"].includes("Recipe"))) {
    return data;
  }

  // Check @graph array
  if (data["@graph"] && Array.isArray(data["@graph"])) {
    for (const item of data["@graph"]) {
      const recipe = findRecipeInJsonLd(item);
      if (recipe) return recipe;
    }
  }

  return null;
}

/**
 * Normalize recipe data to our format
 */
function normalizeRecipe(recipe, sourceUrl) {
  // Parse ingredients
  let ingredients = [];
  if (recipe.recipeIngredient) {
    ingredients = Array.isArray(recipe.recipeIngredient)
      ? recipe.recipeIngredient
      : [recipe.recipeIngredient];
  }

  // Parse instructions - handle various structures (HowToStep, HowToSection, nested arrays)
  let instructions = [];
  if (recipe.recipeInstructions) {
    if (Array.isArray(recipe.recipeInstructions)) {
      recipe.recipeInstructions.forEach(step => {
        if (typeof step === "string") {
          // Plain string instruction
          instructions.push(step);
        } else if (step.text) {
          // HowToStep with text property
          instructions.push(step.text);
        } else if (step.itemListElement && Array.isArray(step.itemListElement)) {
          // HowToSection with nested steps - extract each step separately
          step.itemListElement.forEach(subStep => {
            if (typeof subStep === "string") {
              instructions.push(subStep);
            } else if (subStep.text) {
              instructions.push(subStep.text);
            } else if (subStep.name) {
              instructions.push(subStep.name);
            }
          });
        } else if (step["@type"] === "HowToSection" && step.itemListElement) {
          // Another HowToSection format
          const items = Array.isArray(step.itemListElement) ? step.itemListElement : [step.itemListElement];
          items.forEach(subStep => {
            if (typeof subStep === "string") {
              instructions.push(subStep);
            } else if (subStep.text) {
              instructions.push(subStep.text);
            }
          });
        } else if (step.name && !step.text) {
          // Some sites use name instead of text
          instructions.push(step.name);
        }
      });
    } else if (typeof recipe.recipeInstructions === "string") {
      // Single string - may contain HTML list items or newlines
      let raw = recipe.recipeInstructions;

      // Split on HTML list/paragraph boundaries BEFORE stripping tags
      if (/<li[\s>]/i.test(raw) || /<\/p>/i.test(raw) || /<br\s*\/?>/i.test(raw)) {
        // Replace closing tags with a delimiter, then strip remaining HTML
        raw = raw
          .replace(/<\/li>/gi, "|||SPLIT|||")
          .replace(/<\/p>/gi, "|||SPLIT|||")
          .replace(/<br\s*\/?>/gi, "|||SPLIT|||");
        // Strip remaining HTML tags
        raw = raw.replace(/<[^>]*>/g, "");
        instructions = raw
          .split("|||SPLIT|||")
          .map(s => s.trim())
          .filter(s => s.length > 0);
      } else {
        // No HTML - split on newlines or numbered patterns (1. 2. etc.)
        instructions = raw
          .split(/\n+/)
          .map(s => s.trim())
          .filter(s => s.length > 0);

        // If still just one big block, try splitting on numbered patterns
        if (instructions.length === 1 && instructions[0].length > 200) {
          const numbered = instructions[0].split(/(?=\d+\.\s)/).map(s => s.trim()).filter(s => s.length > 0);
          if (numbered.length > 1) {
            instructions = numbered;
          }
        }
      }
    }
  }

  // Clean HTML from all instructions
  instructions = instructions.map(s => cleanHtmlText(s)).filter(s => s && s.trim().length > 0);

  // Parse image
  let imageUrl = "";
  if (recipe.image) {
    if (typeof recipe.image === "string") {
      imageUrl = recipe.image;
    } else if (Array.isArray(recipe.image)) {
      imageUrl = recipe.image[0];
      if (typeof imageUrl === "object") imageUrl = imageUrl.url || "";
    } else if (recipe.image.url) {
      imageUrl = recipe.image.url;
    }
  }

  // Parse times
  const prepTime = parseDuration(recipe.prepTime);
  const cookTime = parseDuration(recipe.cookTime);
  const totalTime = parseDuration(recipe.totalTime);

  // Parse servings/yield
  let servings = "";
  if (recipe.recipeYield) {
    servings = Array.isArray(recipe.recipeYield)
      ? recipe.recipeYield[0]
      : String(recipe.recipeYield);
  }

  // Clean HTML from all text fields
  const cleanedIngredients = ingredients
    .map(i => cleanHtmlText(i))
    .filter(i => i && i.trim());

  const cleanedInstructions = instructions
    .map(i => cleanHtmlText(i))
    .filter(i => i && i.trim());

  return {
    name: cleanHtmlText(recipe.name) || "Untitled Recipe",
    description: cleanHtmlText(recipe.description) || "",
    imageUrl: imageUrl,
    ingredients: cleanedIngredients,
    instructions: cleanedInstructions,
    prepTime: prepTime,
    cookTime: cookTime,
    totalTime: totalTime || (prepTime + cookTime),
    servings: cleanHtmlText(servings),
    sourceUrl: sourceUrl
  };
}

/**
 * Clean HTML tags and decode HTML entities from text
 */
function cleanHtmlText(text) {
  if (!text || typeof text !== "string") return text;

  // Remove HTML tags (like <p id="...">, </p>, <span>, etc.)
  let cleaned = text.replace(/<[^>]*>/g, "");

  // Decode common HTML entities
  const entities = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">",
    "&quot;": '"',
    "&apos;": "'",
    "&#39;": "'",
    "&#x27;": "'",
    "&nbsp;": " ",
    "&#160;": " ",
    "&#8217;": "'",  // Right single quote
    "&#8216;": "'",  // Left single quote
    "&#8220;": '"',  // Left double quote
    "&#8221;": '"',  // Right double quote
    "&#8243;": '"',  // Double prime (inches)
    "&#8242;": "'",  // Prime (feet/minutes)
    "&#176;": "°",   // Degree symbol
    "&#189;": "½",   // Half
    "&#188;": "¼",   // Quarter
    "&#190;": "¾",   // Three quarters
    "&#8211;": "-",  // En dash
    "&#8212;": "-",  // Em dash
    "&#x2019;": "'", // Right single quote (hex)
    "&#x2018;": "'", // Left single quote (hex)
    "&#x201c;": '"', // Left double quote (hex)
    "&#x201d;": '"', // Right double quote (hex)
  };

  for (const [entity, char] of Object.entries(entities)) {
    cleaned = cleaned.split(entity).join(char);
  }

  // Handle numeric entities (decimal)
  cleaned = cleaned.replace(/&#(\d+);/g, (match, dec) => {
    return String.fromCharCode(parseInt(dec, 10));
  });

  // Handle numeric entities (hex)
  cleaned = cleaned.replace(/&#x([0-9a-fA-F]+);/g, (match, hex) => {
    return String.fromCharCode(parseInt(hex, 16));
  });

  // Clean up extra whitespace
  cleaned = cleaned.replace(/\s+/g, " ").trim();

  return cleaned;
}

/**
 * Parse ISO 8601 duration to minutes
 */
function parseDuration(duration) {
  if (!duration) return 0;
  if (typeof duration === "number") return duration;

  const match = String(duration).match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/i);
  if (match) {
    const hours = parseInt(match[1] || 0);
    const minutes = parseInt(match[2] || 0);
    const seconds = parseInt(match[3] || 0);
    return hours * 60 + minutes + Math.round(seconds / 60);
  }

  // Try simple number
  const num = parseInt(duration);
  return isNaN(num) ? 0 : num;
}

/**
 * Parse recipe from pasted text using OpenAI
 */
async function parseRecipeWithAI(text) {
  const openai = getOpenAI();

  const response = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0.1,
    messages: [
      {
        role: "system",
        content: `You are a recipe parser. Extract structured recipe data from user-provided text.
Return ONLY valid JSON with this exact format:
{
  "name": "Recipe Name",
  "description": "Brief description of the dish",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "instructions": ["Step 1 text", "Step 2 text"],
  "prepTime": 10,
  "cookTime": 30,
  "totalTime": 40,
  "servings": "4"
}

Rules:
- ingredients: array of strings, each a single ingredient with quantity (e.g. "2 cups flour")
- instructions: array of strings, each a single step. Remove numbering prefixes like "1." or "Step 1:"
- prepTime/cookTime/totalTime: integers in minutes, use 0 if unknown
- servings: string, use "" if unknown
- If the text is not a recipe at all, return null
- Clean up any formatting artifacts, extra whitespace, or HTML
- Do NOT invent or guess missing information`
      },
      {
        role: "user",
        content: text
      }
    ],
    response_format: { type: "json_object" },
  });

  const content = response.choices[0]?.message?.content;
  if (!content) return null;

  try {
    const parsed = JSON.parse(content);
    // Validate minimum required fields
    if (!parsed.name || !Array.isArray(parsed.ingredients) || parsed.ingredients.length === 0) {
      console.log("AI response missing required fields:", parsed);
      return null;
    }
    return {
      name: parsed.name || "Untitled Recipe",
      description: parsed.description || "",
      imageUrl: "",
      ingredients: parsed.ingredients || [],
      instructions: parsed.instructions || [],
      prepTime: parsed.prepTime || 0,
      cookTime: parsed.cookTime || 0,
      totalTime: parsed.totalTime || (parsed.prepTime || 0) + (parsed.cookTime || 0),
      servings: String(parsed.servings || ""),
      sourceUrl: ""
    };
  } catch (e) {
    console.error("Failed to parse AI response:", content, e);
    return null;
  }
}

/**
 * Fallback: Extract from meta tags
 */
function extractFromMetaTags(html, sourceUrl) {
  const getMetaContent = (property) => {
    const match = html.match(new RegExp(`<meta[^>]*(?:property|name)=["']${property}["'][^>]*content=["']([^"']*)["']`, "i")) ||
                  html.match(new RegExp(`<meta[^>]*content=["']([^"']*)["'][^>]*(?:property|name)=["']${property}["']`, "i"));
    return match ? match[1] : "";
  };

  const title = getMetaContent("og:title") ||
                getMetaContent("twitter:title") ||
                (html.match(/<title>([^<]*)<\/title>/i) || [])[1] || "";

  const description = getMetaContent("og:description") ||
                      getMetaContent("description") || "";

  const imageUrl = getMetaContent("og:image") ||
                   getMetaContent("twitter:image") || "";

  if (!title) return null;

  return {
    name: title.trim(),
    description: description.trim(),
    imageUrl: imageUrl,
    ingredients: [],
    instructions: [],
    prepTime: 0,
    cookTime: 0,
    totalTime: 0,
    servings: "",
    sourceUrl: sourceUrl
  };
}
