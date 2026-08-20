// MomRise Cloud Functions - v2 (Node 22)
const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { getAuth } = require('firebase-admin/auth');
const sgMail = require('@sendgrid/mail');
const https = require('https');
const http = require('http');

initializeApp();

// ── Configuration ─────────────────────────────────────
// Non-secret values from .env
const sendgridFromEmail = defineString('SENDGRID_FROM_EMAIL');

// Secret values from Cloud Secret Manager
const sendgridApiKey = defineSecret('SENDGRID_API_KEY');
const openaiApiKey = defineSecret('OPENAI_API_KEY');
const scrapingBeeApiKey = defineSecret('SCRAPINGBEE_API_KEY');
const anthropicApiKey = defineSecret('ANTHROPIC_API_KEY');

// ── Waitlist Welcome Email ───────────────────────────
// Triggered when new document created in 'waitlist' collection
exports.sendWaitlistWelcome = onDocumentCreated(
  {
    document: 'waitlist/{waitlistId}',
    secrets: [sendgridApiKey],
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const { email, email_sent, source } = data;

    // Skip if already sent
    if (email_sent) {
      console.log('Welcome email already sent to:', email);
      return;
    }

    try {
      // Initialize SendGrid
      sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));

      // Email content
      const emailMsg = {
        to: email,
        from: sendgridFromEmail.value(), // noreply@momrise.app (after domain verification)
        subject: 'Welcome to MomRise! Here\'s your free meal plan 🍽️',
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0;
                padding: 0;
                background: #F9FAFB;
                line-height: 1.6;
              }
              .container {
                max-width: 600px;
                margin: 40px auto;
                background: white;
                border-radius: 16px;
                overflow: hidden;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
              }
              .header {
                background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%);
                padding: 40px 24px;
                text-align: center;
                color: white;
              }
              .header h1 {
                margin: 0;
                font-size: 28px;
                font-weight: 700;
              }
              .header p {
                margin: 8px 0 0;
                font-size: 16px;
                opacity: 0.95;
              }
              .content {
                padding: 40px 24px;
                color: #5D4E60;
              }
              .content h2 {
                color: #52A097;
                margin-top: 0;
                font-size: 24px;
              }
              .content p {
                margin: 16px 0;
                font-size: 16px;
              }
              .cta-button {
                display: inline-block;
                background: #52A097;
                color: white !important;
                padding: 16px 32px;
                border-radius: 12px;
                text-decoration: none;
                font-weight: 600;
                margin: 24px 0;
                font-size: 16px;
              }
              .cta-button:hover {
                background: #2A6F67;
              }
              .features {
                background: #F9FAFB;
                padding: 24px;
                border-radius: 12px;
                margin: 24px 0;
              }
              .features ul {
                margin: 0;
                padding-left: 24px;
              }
              .features li {
                margin: 12px 0;
                font-size: 15px;
              }
              .footer {
                background: #F9FAFB;
                padding: 24px;
                text-align: center;
                color: #9B8A9E;
                font-size: 14px;
                border-top: 1px solid #E5E7EB;
              }
              .footer a {
                color: #52A097;
                text-decoration: none;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🎉 You're on the list!</h1>
                <p>Welcome to the MomRise family</p>
              </div>

              <div class="content">
                <h2>Hi there!</h2>

                <p>Thank you for joining our waitlist. We're working hard to launch <strong>MomRise</strong>—the app that helps busy moms plan family meals in 5 minutes (plus learning activities, milestones & calendar).</p>

                <p><strong>Your free gift is waiting:</strong></p>

                <a href="https://momrise.app/free-meal-plan.pdf" class="cta-button">
                  Download Your Free 7-Day Meal Plan
                </a>

                <div class="features">
                  <p><strong>What you'll love about MomRise:</strong></p>
                  <ul>
                    <li>🍽️ <strong>5-Minute Meal Planning</strong> - Budget-friendly recipes with one-tap Instacart integration</li>
                    <li>📅 <strong>Family Calendar</strong> - Plan your week with activities, meals, and reminders</li>
                    <li>📚 <strong>AI Learning Paths</strong> - Turn everyday challenges into growth opportunities</li>
                    <li>🎯 <strong>Milestone Tracking</strong> - Celebrate every achievement, big or small</li>
                  </ul>
                </div>

                <p>Over the next week, I'll send you a few quick emails introducing MomRise's features. No spam, just helpful info about what makes this app special.</p>

                <p><strong>We'll let you know the moment MomRise launches.</strong></p>

                <p>Have questions? Just reply to this email—I read every response.</p>

                <p>Talk soon,<br>
                <strong>The MomRise Team</strong></p>
              </div>

              <div class="footer">
                <p>You're receiving this because you joined the MomRise waitlist at momrise.app</p>
                <p style="margin-top: 16px;">
                  <a href="mailto:hello@momrise.app">Contact Us</a> •
                  <a href="https://momrise.app">Visit Website</a>
                </p>
                <p style="margin-top: 16px; font-size: 12px;">
                  Want to unsubscribe? We'd be sad to see you go, but <a href="mailto:hello@momrise.app?subject=Unsubscribe">click here</a>.
                </p>
              </div>
            </div>
          </body>
          </html>
        `,
        // Plain text version (fallback)
        text: `
🎉 You're on the list!

Hi there!

Thank you for joining our waitlist. We're working hard to launch MomRise—the app that helps busy moms plan family meals in 5 minutes (plus learning activities, milestones & calendar).

Download your free 7-day meal plan: https://momrise.app/free-meal-plan.pdf

What you'll love about MomRise:
• 5-Minute Meal Planning - Budget-friendly recipes with one-tap Instacart integration
• Family Calendar - Plan your week with activities, meals, and reminders
• AI Learning Paths - Turn everyday challenges into growth opportunities
• Milestone Tracking - Celebrate every achievement, big or small

We'll let you know the moment MomRise launches.

Have questions? Just reply to this email.

— The MomRise Team

You're receiving this because you joined the MomRise waitlist at momrise.app
To unsubscribe, email hello@momrise.app
        `.trim()
      };

      // Send email
      await sgMail.send(emailMsg);
      console.log(`Waitlist welcome email sent to ${email} (source: ${source || 'unknown'})`);

      // Mark as sent
      await snap.ref.update({
        email_sent: true,
        email_sent_at: FieldValue.serverTimestamp()
      });

    } catch (error) {
      console.error('Error sending waitlist email to', email, ':', error);

      // Log error to document (for debugging)
      await snap.ref.update({
        email_error: error.message,
        email_error_at: FieldValue.serverTimestamp()
      });
    }
  }
);

// ── Recipe Extraction Function ──────────────────────

// Shared guidance injected into every recipe-extraction prompt. Two goals:
//   1) Anchor generic terms to the SKU shoppers usually buy, so the grocery
//      list and Instacart submission collapse cleanly. ("flour" alone makes
//      the dedupe step guess; "all-purpose flour" is unambiguous.)
//   2) Surface ambiguity to the user instead of guessing. Any ingredient the
//      model genuinely can't disambiguate goes in confidence_flags with a
//      one-line reason, and the UI shows a "review" badge on that row.
const RECIPE_SPECIFICITY_RULES = `
INGREDIENT SPECIFICITY (very important for grocery deduplication):
When the source recipe uses a generic term, output the most common shopper-default specific form. This prevents duplicate buys at checkout.
- "flour"        -> "all-purpose flour"
- "sugar"        -> "granulated sugar"
- "brown sugar"  -> "light brown sugar"
- "butter"       -> "salted butter"
- "milk"         -> "whole milk"
- "rice"         -> "long-grain white rice"
- "oil"          -> "vegetable oil"  (unless the recipe clearly implies olive/sesame/etc.)
- "onion"        -> "yellow onion"
- "salt"         -> "kosher salt"
- "eggs"         -> "large eggs"
- "cheese"       -> keep specific (cheddar, mozzarella, parmesan); if truly generic, output "shredded cheddar cheese"
- "broth/stock"  -> "low-sodium chicken broth" unless beef/veg is clearly implied
- "vinegar"      -> "distilled white vinegar"
- "pasta"        -> keep the called-out shape (spaghetti, penne...); if generic, output "spaghetti"
If the recipe is EXPLICIT about a different form (e.g. "unsalted butter", "cake flour", "2% milk"), keep what it says — don't override the recipe.

CONFIDENCE FLAGS (optional output field):
Add a "confidence_flags" array for any ingredient where you had to guess and a wrong guess would change what the shopper buys. Each entry: { "ingredient": "<the exact string you emitted>", "reason": "<one short sentence>" }. Examples worth flagging: ambiguous cheese ("cheese" with no type hint), ambiguous oil if the cuisine doesn't make it obvious, a quantity you couldn't parse, a recipe that mixes US and metric units inconsistently. Skip the field entirely (or leave empty) when nothing is ambiguous. Be sparing — only flag when the call genuinely affects the grocery run.
`.trim();

// HTTP request function to extract recipe from URL
// This uses onRequest to bypass App Check (matching the Flutter code expectation)
async function addCostEstimate(recipe, apiKey) {
  if (!recipe || !recipe.ingredients || recipe.ingredients.length === 0) return recipe;
  if (typeof recipe.estimatedCost === 'number' && recipe.estimatedCost > 0) return recipe;
  try {
    const cost = await estimateRecipeCost(recipe.ingredients, apiKey);
    if (cost > 0) {
      recipe.estimatedCost = cost;
      console.log(`Cost estimate: $${cost.toFixed(2)}`);
    }
  } catch (e) {
    console.log(`Cost estimation failed (non-blocking): ${e.message}`);
  }
  return recipe;
}

// Rate limiting: max 30 extractions per user per hour
const _rateLimitMap = new Map();
const RATE_LIMIT_MAX = 30;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;

function checkRateLimit(uid) {
  const now = Date.now();
  const entry = _rateLimitMap.get(uid);
  if (!entry || now - entry.windowStart > RATE_LIMIT_WINDOW_MS) {
    _rateLimitMap.set(uid, { windowStart: now, count: 1 });
    return true;
  }
  if (entry.count >= RATE_LIMIT_MAX) return false;
  entry.count++;
  return true;
}

exports.extractRecipe = onRequest({ secrets: [openaiApiKey, scrapingBeeApiKey] }, async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight OPTIONS request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  // Verify Firebase Auth token
  const authHeader = request.headers.authorization;
  let uid = null;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    try {
      const { getAuth } = require('firebase-admin/auth');
      const token = authHeader.split('Bearer ')[1];
      const decoded = await getAuth().verifyIdToken(token);
      uid = decoded.uid;
    } catch (authError) {
      console.error('Auth verification failed:', authError.message);
    }
  }

  if (!uid) {
    response.status(401).json({ result: { error: 'Authentication required' } });
    return;
  }

  if (!checkRateLimit(uid)) {
    response.status(429).json({ result: { error: 'Rate limit exceeded. Try again later.' } });
    return;
  }

  // Extract URL or text from request body
  const { data } = request.body;
  const { url, text } = data || {};

  if (!url && !text) {
    response.status(400).json({
      result: { error: 'URL or text is required' }
    });
    return;
  }

  // Pinterest is blocked on the *creator* path only (consumer mobile
  // users keep the pin-import behavior they had). Reasoning:
  // - Pinterest's ToS prohibits automated scraping regardless of
  //   commercial intent, so this is a soft legal violation either way.
  // - The pinned image belongs to the original creator, not the
  //   pinner — copyright concern.
  // - The risk multiplies when the importer is publishing or selling
  //   the result. So on the monetizable creator path we refuse pins;
  //   on the consumer-personal path we preserve the existing UX and
  //   accept the lower (but non-zero) risk.
  // Callers signal intent with data.context = 'creator'. Mobile app
  // sends no context value and keeps its current behavior unchanged.
  const fromCreator = data && data.context === 'creator';
  if (fromCreator && url) {
    const urlLower = url.toLowerCase();
    if (
      urlLower.includes('pinterest.com') ||
      urlLower.includes('pin.it') ||
      urlLower.includes('pinimg.com')
    ) {
      response.status(400).json({
        result: {
          error: 'pinterest_not_supported',
          message: "Pinterest pins aren't supported on the creator path. Try the source blog URL (look for a link in the pin), snap a photo of the recipe, or paste the recipe text directly.",
        },
      });
      return;
    }
  }

  // If text is provided, use AI to extract recipe from pasted text
  if (text && !url) {
    console.log(`Extracting recipe from pasted text (length: ${text.length})`);
    try {
      const recipe = await extractRecipeFromTextWithAI(text, openaiApiKey.value());
      console.log(`AI extracted recipe: ${recipe.name}`);
      await addCostEstimate(recipe, openaiApiKey.value());
      response.status(200).json({ result: { success: true, recipe } });
      return;
    } catch (error) {
      console.error(`Text extraction error: ${error.message}`);
      response.status(500).json({
        result: { success: false, error: `Failed to extract recipe from text: ${error.message}` }
      });
      return;
    }
  }

  console.log(`Extracting recipe from URL: ${url}`);

  // TikTok shortcut: use the official oEmbed API rather than scraping the
  // page. TikTok's URL serves a JS-rendered SPA that has no recipe content
  // in the initial HTML anyway, but their oEmbed endpoint is public, no-auth,
  // and explicitly sanctioned for embed widgets. Returns the caption in the
  // `title` field, which we then feed to the existing AI text parser.
  //
  // IMPORTANT: TikTok's oEmbed only supports VIDEO posts (/video/...). PHOTO
  // carousel posts (/photo/...) return HTTP 400. We detect the photo case
  // after resolving the URL and surface a specific "use a screenshot" error.
  if (url.includes('tiktok.com')) {
    console.log('TikTok URL detected — calling oEmbed');
    try {
      const recipe = await extractRecipeFromTikTok(url, openaiApiKey.value());
      if (recipe && recipe.name) {
        console.log(`TikTok recipe extracted: ${recipe.name}`);
        await addCostEstimate(recipe, openaiApiKey.value());
        response.status(200).json({ result: recipe });
        return;
      }
      // Recipe object is null in three cases the extractor signals:
      //   - empty/short caption (voiceover-only video)
      //   - photo carousel without recipe text on the cover slide
      //   - any other oEmbed / OCR failure path
      // Status 200 (not 4xx) so makeCloudCall on the client passes the
      // body through to the error-handler that uses `result.message`
      // instead of falling through to the URL-pattern catch block.
      response.status(200).json({
        result: {
          error: 'TIKTOK_NO_RECIPE_IN_CAPTION',
          message:
            "We couldn't read a recipe from this TikTok. The recipe might be in the voiceover, or this is a photo post we can't read directly. Try a screenshot of it — tap 'Import from photo' below.",
        },
      });
      return;
    } catch (tiktokError) {
      console.error(`TikTok oEmbed failed: ${tiktokError.message}`);
      response.status(200).json({
        result: {
          error: 'TIKTOK_FETCH_FAILED',
          message:
            "Couldn't load this TikTok. It might be private, deleted, or the link's wrong. Try a screenshot instead — tap 'Import from photo' below.",
        },
      });
      return;
    }
  }

  try {
    // Try direct fetch first (free), fall back to ScrapingBee on failure
    let html;
    let fetchMethod = 'direct';
    try {
      html = await fetchUrl(url);
      // Check if we got a real page or a Cloudflare challenge/block
      if (html.length < 500 || html.includes('Just a moment') || html.includes('cf-browser-verification') || html.includes('Enable JavaScript')) {
        throw new Error('Blocked by Cloudflare or bot protection');
      }
      console.log(`Direct fetch succeeded (length: ${html.length})`);
    } catch (directError) {
      console.log(`Direct fetch failed: ${directError.message} — trying ScrapingBee...`);
      try {
        html = await fetchWithScrapingBee(url, scrapingBeeApiKey.value());
        fetchMethod = 'scrapingbee';
        console.log(`ScrapingBee fetch succeeded (length: ${html.length})`);
      } catch (sbError) {
        console.error(`ScrapingBee also failed: ${sbError.message}`);
        throw new Error(`Could not access this website. ${directError.message}`);
      }
    }
    console.log(`Fetched HTML via ${fetchMethod} (length: ${html.length})`);

    // Check if this is a Pinterest pin (not a recipe site)
    const finalUrl = url.includes('pin.it') || url.includes('pinterest.com')
      ? 'pinterest.com'
      : url;

    if (finalUrl.includes('pinterest.com') || html.includes('SocialMediaPosting')) {

      // Check for Pinterest login wall
      if (html.includes('LoginPage') || html.includes('unauthHomepage') || (html.includes('log in') && html.length < 5000)) {
        console.log('Pinterest login wall detected');
        response.status(403).json({
          result: { error: 'PINTEREST_LOGIN_WALL', message: 'Pinterest is requiring a login to view this pin. Open it in the Pinterest app, tap the source link, and share that URL instead.' }
        });
        return;
      }

      // Check for video pin
      if (html.includes('"video"') || html.includes('VideoObject') || html.includes('video_list')) {
        console.log('Video pin detected');
        // Still try source URL extraction — video pins can have recipe links
      }

      // Try to extract the source URL from Pinterest pin
      const sourceUrl = extractPinterestSourceUrl(html);
      if (sourceUrl) {
        console.log(`Found Pinterest source URL: ${sourceUrl}`);

        // Check if source links to social media (not a recipe site)
        const socialDomains = ['instagram.com', 'tiktok.com', 'facebook.com', 'twitter.com', 'x.com'];
        if (socialDomains.some(d => sourceUrl.includes(d))) {
          console.log(`Source URL is social media: ${sourceUrl}`);
          response.status(404).json({
            result: { error: 'PINTEREST_SOCIAL_SOURCE', message: 'This pin links to social media, not a recipe website. Try finding the recipe on the creator\'s blog instead.' }
          });
          return;
        }

        // Check if source links to a product page
        const productDomains = ['amazon.com', 'etsy.com', 'walmart.com', 'target.com', 'ebay.com'];
        if (productDomains.some(d => sourceUrl.includes(d))) {
          console.log(`Source URL is product page: ${sourceUrl}`);
          response.status(404).json({
            result: { error: 'PINTEREST_PRODUCT_SOURCE', message: 'This pin links to a product page, not a recipe. Try a different pin.' }
          });
          return;
        }

        // Fetch the actual recipe from source (try direct, then ScrapingBee)
        let sourceHtml;
        try {
          sourceHtml = await fetchUrl(sourceUrl);
          if (sourceHtml.length < 500 || sourceHtml.includes('Just a moment')) {
            throw new Error('Blocked');
          }
        } catch (fetchError) {
          console.log(`Direct fetch of source failed: ${fetchError.message}, trying ScrapingBee...`);
          try {
            sourceHtml = await fetchWithScrapingBee(sourceUrl, scrapingBeeApiKey.value());
          } catch (sbError) {
            console.error(`ScrapingBee also failed for source: ${sbError.message}`);
            // Source site is dead or unreachable
            response.status(404).json({
              result: { error: 'PINTEREST_SOURCE_DEAD', message: 'The recipe website linked from this pin is no longer available. Try pasting the recipe text instead.' }
            });
            return;
          }
        }

        const recipe = extractRecipeFromHtml(sourceHtml, sourceUrl);
        if (recipe) {
          console.log(`Successfully extracted recipe: ${recipe.name}`);
          await addCostEstimate(recipe, openaiApiKey.value());
          response.status(200).json({ result: recipe });
          return;
        }

        // Source HTML fetched but no structured recipe — try OpenAI on source HTML
        console.log('No structured recipe in source, trying OpenAI on source HTML...');
        try {
          const aiRecipe = await extractRecipeWithAI(sourceHtml, sourceUrl, openaiApiKey.value());
          if (aiRecipe && aiRecipe.name) {
            console.log(`AI extracted from source: ${aiRecipe.name}`);
            await addCostEstimate(aiRecipe, openaiApiKey.value());
            response.status(200).json({ result: aiRecipe });
            return;
          }
        } catch (aiError) {
          console.error(`AI extraction from source failed: ${aiError.message}`);
        }
      }

      // No source URL or source extraction failed
      // Try to extract recipe from the pin's image using OpenAI Vision
      console.log('No source recipe found, trying image-based extraction...');
      const pinImageUrl = extractPinterestImageUrl(html);
      if (pinImageUrl) {
        console.log(`Found pin image: ${pinImageUrl}`);
        try {
          const recipe = await extractRecipeFromImageWithAI(pinImageUrl, openaiApiKey.value());
          if (recipe && recipe.name) {
            recipe.imageUrl = pinImageUrl;
            recipe.sourceUrl = url;
            console.log(`Vision extracted recipe: ${recipe.name}`);
            await addCostEstimate(recipe, openaiApiKey.value());
            response.status(200).json({ result: recipe });
            return;
          }
        } catch (visionError) {
          console.error(`Vision extraction failed: ${visionError.message}`);
        }
      }

      // Check if it was a video pin (give specific message)
      if (html.includes('"video"') || html.includes('VideoObject') || html.includes('video_list')) {
        response.status(404).json({
          result: { error: 'PINTEREST_VIDEO', message: 'Video pins can\'t be imported yet. Try finding the recipe on the creator\'s website or blog.' }
        });
        return;
      }

      // All Pinterest methods failed — food photo only
      response.status(404).json({
        result: { error: 'PINTEREST_NO_RECIPE', message: 'This pin is just a food photo — no recipe text found. Try searching for the recipe by name, or tap "Paste Text" to add it manually.' }
      });
      return;
    }

    // Extract recipe from HTML using structured data
    let recipe = extractRecipeFromHtml(html, url);

    // Check if recipe is incomplete (no ingredients or only 1 instruction)
    const isIncomplete = !recipe ||
      recipe.ingredients.length === 0 ||
      recipe.instructions.length <= 1;

    if (isIncomplete) {
      console.log('Recipe extraction incomplete or failed, trying OpenAI fallback...');

      try {
        recipe = await extractRecipeWithAI(html, url, openaiApiKey.value());
        console.log(`AI extracted recipe: ${recipe.name}`);
      } catch (aiError) {
        console.error(`AI extraction failed: ${aiError.message}`);

        // If we have a partial recipe from structured data, return it
        if (recipe) {
          console.log('Returning partial recipe from structured data');
          await addCostEstimate(recipe, openaiApiKey.value());
          response.status(200).json({ result: recipe });
          return;
        }

        // Complete failure
        response.status(404).json({
          result: { error: 'No recipe found at this URL' }
        });
        return;
      }
    } else {
      // Recipe extracted successfully from structured data, but let AI validate and fix any issues
      console.log(`Recipe extracted: ${recipe.name}, ${recipe.instructions.length} instructions`);
      console.log(`First instruction: ${recipe.instructions[0]?.substring(0, 100)}...`);
      console.log('Sending to AI for validation...');
      try {
        const validatedRecipe = await validateRecipeWithAI(recipe, html, openaiApiKey.value());
        if (validatedRecipe) {
          console.log(`AI improved recipe: ${recipe.instructions.length} -> ${validatedRecipe.instructions.length} steps`);
          recipe = validatedRecipe;
        } else {
          console.log('AI validation: no improvements needed');
        }
      } catch (validationError) {
        console.error(`AI validation failed: ${validationError.message}`);
        // Continue with original recipe if validation fails
      }
    }

    // Estimate cost from ingredients using OpenAI
    if (recipe.ingredients && recipe.ingredients.length > 0) {
      try {
        const costEstimate = await estimateRecipeCost(recipe.ingredients, openaiApiKey.value());
        if (costEstimate > 0) {
          recipe.estimatedCost = costEstimate;
          console.log(`Estimated cost: $${costEstimate.toFixed(2)}`);
        }
      } catch (costError) {
        console.log(`Cost estimation failed (non-blocking): ${costError.message}`);
      }
    }

    console.log(`Returning recipe: ${recipe.name}`);
    console.log(`Instructions count: ${recipe.instructions.length}`);
    console.log(`Instructions: ${JSON.stringify(recipe.instructions).substring(0, 500)}...`);
    response.status(200).json({ result: recipe });

  } catch (error) {
    console.error(`Recipe extraction error: ${error.message}`);
    response.status(500).json({
      result: { error: `Failed to extract recipe: ${error.message}` }
    });
  }
});

// Helper: Extract source URL from Pinterest pin HTML
function extractPinterestSourceUrl(html) {
  // Try to find ALL link fields in Pinterest's data (there may be multiple)
  // The first one is often empty, but later ones contain the actual URL
  const linkMatches = html.match(/"link"\s*:\s*"([^"]*)"/g);

  if (linkMatches) {
    for (const match of linkMatches) {
      const urlMatch = match.match(/"link"\s*:\s*"([^"]*)"/);
      if (urlMatch && urlMatch[1] && urlMatch[1].startsWith('http')) {
        console.log(`Found Pinterest source URL: ${urlMatch[1]}`);
        return urlMatch[1];
      }
    }
  }

  // Fallback: Try to find domain and search for URLs from that domain
  const domainMatch = html.match(/"domain"\s*:\s*"([^"]+)"/);
  if (domainMatch && domainMatch[1] && domainMatch[1] !== 'Uploaded by user') {
    console.log(`Found domain: ${domainMatch[1]}, searching for URLs...`);

    // Search for any URLs from this domain
    const urlPattern = new RegExp(`"(https?://[^"]*${domainMatch[1].replace('.', '\\.')}[^"]*)"`, 'g');
    let match;
    while ((match = urlPattern.exec(html)) !== null) {
      const url = match[1];
      if (!url.includes('pinterest.com') && !url.includes('pinimg.com')) {
        console.log(`Found URL from domain: ${url}`);
        return url;
      }
    }
  }

  return null;
}

// Helper: Fetch URL with redirect following
// Follow HTTP redirects without downloading the response body. Returns the
// final URL after the redirect chain settles. Used to resolve TikTok short
// links (tiktok.com/t/XXX) to canonical URLs that oEmbed accepts. Separate
// from fetchUrl because fetchUrl downloads the body and discards the final
// URL — for redirect resolution we want the URL but not the bytes.
function resolveRedirectUrl(url, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 5) {
      resolve(url);
      return;
    }
    const protocol = url.startsWith('https') ? https : http;
    const request = protocol.request(
      url,
      {
        method: 'GET',
        headers: {
          'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
      },
      (response) => {
        if (
          response.statusCode >= 300 &&
          response.statusCode < 400 &&
          response.headers.location
        ) {
          let redirectUrl = response.headers.location;
          if (redirectUrl.startsWith('/')) {
            const urlObj = new URL(url);
            redirectUrl = `${urlObj.protocol}//${urlObj.host}${redirectUrl}`;
          }
          response.destroy();
          resolve(resolveRedirectUrl(redirectUrl, redirectCount + 1));
        } else {
          response.destroy();
          resolve(url);
        }
      },
    );
    request.on('error', reject);
    request.setTimeout(8000, () => {
      request.destroy();
      reject(new Error('Redirect resolve timed out'));
    });
    request.end();
  });
}

function fetchUrl(url, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 5) {
      reject(new Error('Too many redirects'));
      return;
    }

    const protocol = url.startsWith('https') ? https : http;

    const request = protocol.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'identity',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Sec-Ch-Ua': '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Upgrade-Insecure-Requests': '1',
      }
    }, (response) => {
      // Handle redirects
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        let redirectUrl = response.headers.location;
        console.log(`Redirect to: ${redirectUrl}`);

        // Detect Pinterest shortlinks that redirect to homepage (pin not accessible)
        if ((url.includes('pin.it') || url.includes('pinterest.com')) &&
            redirectUrl === 'https://www.pinterest.com' || redirectUrl === 'https://www.pinterest.com/') {
          reject(new Error('Pinterest isn\'t sharing the recipe link for this pin. The pin may be private or have no website link. Try opening the pin in Pinterest and looking for a "Visit" button.'));
          return;
        }

        if (redirectUrl.startsWith('/')) {
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

      let data = '';
      response.on('data', (chunk) => {
        data += chunk;
      });
      response.on('end', () => {
        resolve(data);
      });
    });

    request.on('error', reject);
    request.setTimeout(30000, () => {
      request.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

// Helper: Fetch URL using ScrapingBee with tiered fallback to save credits.
// Tier 1: JS only (5 credits) — handles most JS-rendered sites
// Tier 2: JS + premium proxy (25 credits) — handles Cloudflare + aggressive bot detection
function fetchWithScrapingBee(url, apiKey) {
  return new Promise(async (resolve, reject) => {
    if (!apiKey) {
      reject(new Error('ScrapingBee API key not configured'));
      return;
    }

    // Tier 1: JS rendering only (5 credits)
    try {
      console.log('ScrapingBee Tier 1: JS only (5 credits)...');
      const html = await _scrapingBeeRequest(url, apiKey, { render_js: 'true', premium_proxy: 'false' });
      console.log(`ScrapingBee Tier 1 succeeded (length: ${html.length})`);
      resolve(html);
      return;
    } catch (tier1Error) {
      console.log(`ScrapingBee Tier 1 failed: ${tier1Error.message}`);
    }

    // Tier 2: JS + premium proxy (25 credits)
    try {
      console.log('ScrapingBee Tier 2: JS + premium proxy (25 credits)...');
      const html = await _scrapingBeeRequest(url, apiKey, { render_js: 'true', premium_proxy: 'true' });
      console.log(`ScrapingBee Tier 2 succeeded (length: ${html.length})`);
      resolve(html);
    } catch (tier2Error) {
      console.log(`ScrapingBee Tier 2 failed: ${tier2Error.message}`);
      reject(tier2Error);
    }
  });
}

function _scrapingBeeRequest(url, apiKey, options) {
  return new Promise((resolve, reject) => {
    const params = new URLSearchParams({
      api_key: apiKey,
      url: url,
      render_js: options.render_js || 'false',
      premium_proxy: options.premium_proxy || 'false',
      country_code: 'us',
    });

    const sbUrl = `https://app.scrapingbee.com/api/v1/?${params.toString()}`;

    https.get(sbUrl, {
      timeout: 45000,
    }, (response) => {
      if (response.statusCode !== 200) {
        let errorBody = '';
        response.on('data', (chunk) => { errorBody += chunk; });
        response.on('end', () => {
          console.error(`ScrapingBee HTTP ${response.statusCode}: ${errorBody.substring(0, 200)}`);
          reject(new Error(`ScrapingBee HTTP ${response.statusCode}`));
        });
        return;
      }

      let data = '';
      response.on('data', (chunk) => {
        data += chunk;
      });
      response.on('end', () => {
        if (data.length < 100) {
          reject(new Error('ScrapingBee returned empty response'));
          return;
        }
        resolve(data);
      });
    }).on('error', (err) => {
      reject(new Error(`ScrapingBee request failed: ${err.message}`));
    }).setTimeout(45000, function() {
      this.destroy();
      reject(new Error('ScrapingBee request timeout'));
    });
  });
}

// Helper: Extract recipe from HTML using JSON-LD
function extractRecipeFromHtml(html, sourceUrl) {
  // Try to find JSON-LD structured data
  // Match both quoted and unquoted type attributes, with or without space after <script
  // Handles: <script type="application/ld+json">, <script type=application/ld+json>, <scripttype=application/ld+json>
  const jsonLdMatches = html.match(/<script\s*[^>]*type=["']?application\/ld\+json["']?[^>]*>([\s\S]*?)<\/script>/gi);

  console.log(`Found JSON-LD blocks: ${jsonLdMatches ? jsonLdMatches.length : 0}`);

  if (jsonLdMatches) {
    for (let i = 0; i < jsonLdMatches.length; i++) {
      const match = jsonLdMatches[i];
      try {
        const jsonContent = match.replace(/<script[^>]*>|<\/script>/gi, '').trim();
        const data = JSON.parse(jsonContent);

        console.log(`Block ${i + 1} @type: ${data['@type'] || (data['@graph'] ? '@graph array' : 'unknown')}`);

        // Handle array of items
        const items = Array.isArray(data) ? data : [data];

        for (const item of items) {
          const recipe = findRecipeInJsonLd(item);
          if (recipe) {
            console.log('Found Recipe!');
            return normalizeRecipe(recipe, sourceUrl);
          }
        }
      } catch (e) {
        console.log(`Block ${i + 1} parse error: ${e.message}`);
        continue;
      }
    }
  }

  return null;
}

// Helper: Find recipe in JSON-LD data
function findRecipeInJsonLd(data) {
  if (!data) return null;

  // Direct recipe
  if (data['@type'] === 'Recipe' ||
      (Array.isArray(data['@type']) && data['@type'].includes('Recipe'))) {
    return data;
  }

  // Check @graph array
  if (data['@graph'] && Array.isArray(data['@graph'])) {
    for (const item of data['@graph']) {
      const recipe = findRecipeInJsonLd(item);
      if (recipe) return recipe;
    }
  }

  return null;
}

// Helper: Normalize recipe data
function normalizeRecipe(recipe, sourceUrl) {
  // Parse ingredients
  let ingredients = [];
  if (recipe.recipeIngredient) {
    ingredients = Array.isArray(recipe.recipeIngredient)
      ? recipe.recipeIngredient
      : [recipe.recipeIngredient];
  }

  // Parse instructions
  let instructions = [];
  if (recipe.recipeInstructions) {
    if (Array.isArray(recipe.recipeInstructions)) {
      recipe.recipeInstructions.forEach(step => {
        if (typeof step === 'string') {
          instructions.push(step);
        } else if (step.text) {
          instructions.push(step.text);
        } else if (step.itemListElement && Array.isArray(step.itemListElement)) {
          // HowToSection with nested steps - extract each step separately
          step.itemListElement.forEach(item => {
            if (typeof item === 'string') {
              instructions.push(item);
            } else if (item.text) {
              instructions.push(item.text);
            } else if (typeof item === 'object') {
              instructions.push(String(item));
            }
          });
        } else {
          instructions.push(String(step));
        }
      });
    } else if (typeof recipe.recipeInstructions === 'string') {
      instructions = recipe.recipeInstructions.split(/\n+/).filter(s => s.trim());
    }
  }

  // Parse image
  let imageUrl = '';
  if (recipe.image) {
    if (typeof recipe.image === 'string') {
      imageUrl = recipe.image;
    } else if (Array.isArray(recipe.image)) {
      imageUrl = recipe.image[0];
      if (typeof imageUrl === 'object') imageUrl = imageUrl.url || '';
    } else if (recipe.image.url) {
      imageUrl = recipe.image.url;
    }
  }

  // Fix WordPress thumbnail URLs - remove size suffixes like -150x150-1, -300x200, etc.
  // Example: image-150x150-1.webp -> image.webp
  if (imageUrl && imageUrl.includes('wp-content/uploads')) {
    imageUrl = imageUrl.replace(/-\d+x\d+(-\d+)?\.(jpg|jpeg|png|webp|gif)/i, '.$2');
    console.log(`Fixed WordPress thumbnail URL to full-size: ${imageUrl}`);
  }

  // Parse servings - handle arrays and clean duplicate text
  let servings = '';
  if (recipe.recipeYield) {
    if (Array.isArray(recipe.recipeYield)) {
      // Take the first numeric value or first item
      const numericItem = recipe.recipeYield.find(item => /^\d+$/.test(String(item).trim()));
      servings = numericItem ? String(numericItem) : String(recipe.recipeYield[0]);
    } else {
      servings = String(recipe.recipeYield);
    }
    // Clean duplicate text like "4,4 servings" or "4,serves 4"
    servings = servings.replace(/^(\d+),\s*(\d+\s*servings?|serves?\s*\d+)$/i, '$1');
    console.log(`Cleaned servings from "${recipe.recipeYield}" to "${servings}"`);
  }

  // Parse ISO 8601 durations (e.g. "PT1H30M", "PT15M") to minutes
  const parseDurationToMinutes = (val) => {
    if (val == null) return 0;
    if (typeof val === 'number') return Math.round(val);
    const s = String(val).trim();
    const iso = s.match(/^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$/i);
    if (iso) {
      const h = parseInt(iso[1] || '0', 10);
      const m = parseInt(iso[2] || '0', 10);
      return h * 60 + m;
    }
    const numMatch = s.match(/(\d+)/);
    return numMatch ? parseInt(numMatch[1], 10) : 0;
  };

  const prepTime = parseDurationToMinutes(recipe.prepTime);
  const cookTime = parseDurationToMinutes(recipe.cookTime);
  console.log(`Parsed times: prep=${prepTime}min (from "${recipe.prepTime}"), cook=${cookTime}min (from "${recipe.cookTime}")`);

  return {
    name: recipe.name || 'Untitled Recipe',
    description: recipe.description || '',
    imageUrl: imageUrl,
    ingredients: ingredients.filter(i => i && i.trim()),
    instructions: instructions.filter(i => i && i.trim()),
    servings: servings,
    prepTime: prepTime,
    cookTime: cookTime,
    sourceUrl: sourceUrl
  };
}

// Helper: Extract recipe using OpenAI when structured data fails
async function extractRecipeWithAI(html, sourceUrl, apiKey) {
  apiKey = apiKey.trim();
  // Strip HTML to just text content (remove scripts, styles, etc.)
  const cleanHtml = html
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  // Truncate to fit in OpenAI context (keep first 12000 chars, roughly 3000 tokens)
  const truncatedHtml = cleanHtml.substring(0, 12000);

  const prompt = `Extract the recipe from this webpage content. Return ONLY valid JSON with this exact structure:
{
  "name": "Recipe Name",
  "description": "Brief description",
  "imageUrl": "image URL if found, empty string if not",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", ...],
  "servings": "number of servings",
  "prepTime": 15,
  "cookTime": 30,
  "confidence_flags": []
}

Important:
- Extract ALL ingredients as separate array items
- Extract ALL instruction steps as separate array items
- If servings shows "4,serves 4", just return "4"
- prepTime and cookTime must be integers in MINUTES (not strings, not ISO durations). Use 0 if not found.
- Do not include any text outside the JSON
- Return empty strings/arrays if data not found

${RECIPE_SPECIFICITY_RULES}

Webpage content:
${truncatedHtml}`;

  const requestBody = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You are a recipe extraction assistant. Return only valid JSON, no markdown formatting.' },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 2000
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.openai.com',
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`OpenAI API error: ${res.statusCode} - ${data}`));
          return;
        }

        try {
          const response = JSON.parse(data);
          const content = response.choices[0].message.content.trim();

          // Remove markdown code blocks if present
          const jsonContent = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();

          const recipe = JSON.parse(jsonContent);

          // Add sourceUrl
          recipe.sourceUrl = sourceUrl;

          // Validate required fields
          if (!recipe.name || !Array.isArray(recipe.ingredients) || !Array.isArray(recipe.instructions)) {
            reject(new Error('AI returned invalid recipe structure'));
            return;
          }

          resolve(recipe);
        } catch (parseError) {
          reject(new Error(`Failed to parse AI response: ${parseError.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(30000, () => {
      req.destroy();
      reject(new Error('OpenAI request timeout'));
    });

    req.write(requestBody);
    req.end();
  });
}

// Helper: Validate and fix recipe extracted from structured data
async function validateRecipeWithAI(recipe, html, apiKey) {
  // Strip HTML for context
  const cleanHtml = html
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .substring(0, 8000); // Smaller context since we already have partial data

  const prompt = `Review and correct this recipe that was extracted from structured data. Fix any errors:

CURRENT RECIPE:
${JSON.stringify(recipe, null, 2)}

ISSUES TO FIX:
1. If "instructions" array has combined steps (like "Preheat...Place chicken...In a bowl..."), split them into separate steps
2. If "servings" has duplicated text like "4,serves 4" or "4,4 servings", clean to just "4"
3. If ingredients are missing, extract them from the webpage
4. If instructions are incomplete or only 1 step, extract all steps from the webpage
5. Make sure each instruction is a single clear step

WEBPAGE CONTENT (for reference):
${cleanHtml}

Return ONLY valid JSON with the CORRECTED recipe in this exact structure:
{
  "name": "Recipe Name",
  "description": "Brief description",
  "imageUrl": "image URL",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", "step 3", ...],
  "servings": "4",
  "prepTime": ${recipe.prepTime || 0},
  "cookTime": ${recipe.cookTime || 0},
  "sourceUrl": "${recipe.sourceUrl}",
  "confidence_flags": []
}

CRITICAL:
- Split combined instruction steps into separate array items
- Each instruction should be ONE action/step only
- Do not combine multiple steps into one string
- Clean up servings format

${RECIPE_SPECIFICITY_RULES}`;

  const requestBody = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You are a recipe validation assistant. Return only valid JSON with corrected recipe data.' },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 2000
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.openai.com',
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`OpenAI API error: ${res.statusCode}`));
          return;
        }

        try {
          const response = JSON.parse(data);
          const content = response.choices[0].message.content.trim();
          const jsonContent = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
          const validatedRecipe = JSON.parse(jsonContent);

          // Only return if we actually improved the recipe
          if (validatedRecipe.instructions.length > recipe.instructions.length ||
              validatedRecipe.ingredients.length > recipe.ingredients.length ||
              validatedRecipe.servings !== recipe.servings) {
            console.log(`Validation improved recipe: ${recipe.instructions.length} -> ${validatedRecipe.instructions.length} steps`);
            resolve(validatedRecipe);
          } else {
            resolve(null); // No improvements needed
          }
        } catch (parseError) {
          reject(new Error(`Failed to parse AI validation: ${parseError.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(30000, () => {
      req.destroy();
      reject(new Error('Validation timeout'));
    });

    req.write(requestBody);
    req.end();
  });
}


// Helper: Extract recipe from pasted text using AI
// Helper: Extract the main image URL from a Pinterest pin HTML
function extractPinterestImageUrl(html) {
  // Try og:image meta tag first (most reliable)
  const ogMatch = html.match(/<meta\s+property="og:image"\s+content="([^"]+)"/i) ||
                  html.match(/<meta\s+content="([^"]+)"\s+property="og:image"/i);
  if (ogMatch && ogMatch[1]) {
    // Upgrade to full resolution
    return ogMatch[1]
      .replace('/236x/', '/originals/')
      .replace('/474x/', '/originals/')
      .replace('/564x/', '/originals/')
      .replace('/736x/', '/originals/');
  }

  // Try finding pinimg URLs in the HTML
  const pinimgMatch = html.match(/(https:\/\/i\.pinimg\.com\/[^"'\s]+)/);
  if (pinimgMatch && pinimgMatch[1]) {
    return pinimgMatch[1]
      .replace('/236x/', '/originals/')
      .replace('/474x/', '/originals/')
      .replace('/564x/', '/originals/')
      .replace('/736x/', '/originals/');
  }

  return null;
}

// Helper: Extract recipe from an image using OpenAI Vision (GPT-4o)
// Used for Pinterest pins that are photos of recipe cards/text
async function extractRecipeFromImageWithAI(imageUrl, apiKey) {
  apiKey = apiKey.trim();
  console.log(`Extracting recipe from image with AI Vision: ${imageUrl}`);

  const requestBody = JSON.stringify({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: 'You are a recipe extraction assistant. You read recipe text from images and return structured JSON. If the image does not contain a recipe, return {"error": "no recipe found"}.'
      },
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: `Look at this image. If it contains a recipe (ingredients, instructions, or recipe text), extract it into this JSON format:
{
  "name": "Recipe Name",
  "description": "Brief description",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "instructions": ["step 1", "step 2"],
  "servings": "number if visible",
  "prepTime": 15,
  "cookTime": 30,
  "confidence_flags": []
}

prepTime and cookTime must be integers in MINUTES (0 if not visible).
If the image is just a food photo with no recipe text, return {"error": "no recipe found"}.
Return ONLY valid JSON.

${RECIPE_SPECIFICITY_RULES}`
          },
          {
            type: 'image_url',
            image_url: { url: imageUrl, detail: 'high' }
          }
        ]
      }
    ],
    temperature: 0.1,
    max_tokens: 2000
  });

  return new Promise((resolve, reject) => {
    const req = https.request('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      }
    }, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.error) {
            reject(new Error(`OpenAI Vision error: ${response.error.message}`));
            return;
          }

          const content = response.choices[0].message.content.trim();
          // Strip markdown code fences if present
          const cleanJson = content.replace(/^```json?\n?/i, '').replace(/\n?```$/i, '');
          const recipe = JSON.parse(cleanJson);

          if (recipe.error) {
            reject(new Error(recipe.error));
            return;
          }

          resolve(recipe);
        } catch (parseError) {
          reject(new Error(`Failed to parse Vision response: ${parseError.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(45000, () => {
      req.destroy();
      reject(new Error('Vision request timeout'));
    });

    req.write(requestBody);
    req.end();
  });
}

// Helper: Estimate recipe cost from ingredients using OpenAI
async function estimateRecipeCost(ingredients, apiKey) {
  apiKey = apiKey.trim();
  const ingredientList = ingredients.slice(0, 20).join('\n');

  const requestBody = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You estimate grocery costs. Return ONLY a number (the total cost in USD). No text, no dollar sign, just the number. Be conservative - use average US grocery prices.' },
      { role: 'user', content: `Estimate the total grocery cost in USD for these ingredients:\n${ingredientList}` }
    ],
    temperature: 0.1,
    max_tokens: 20
  });

  return new Promise((resolve, reject) => {
    const req = https.request('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      }
    }, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.error) {
            reject(new Error(response.error.message));
            return;
          }
          const content = response.choices[0].message.content.trim();
          const cost = parseFloat(content.replace(/[^0-9.]/g, ''));
          resolve(isNaN(cost) ? 0 : cost);
        } catch (e) {
          reject(new Error(`Parse error: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(10000, () => {
      req.destroy();
      reject(new Error('Cost estimation timeout'));
    });

    req.write(requestBody);
    req.end();
  });
}

// Extract a recipe from a TikTok URL via the public oEmbed API. Sanctioned
// access (no auth, no scraping, no ToS gray area). Returns null when the
// caption is too short to plausibly contain a recipe — caller surfaces a
// "try a screenshot" fallback in that case.
//
// Reference: https://developers.tiktok.com/doc/embed-videos (oEmbed section)
async function extractRecipeFromTikTok(url, openaiKey) {
  // TikTok's share button hands users a short link like tiktok.com/t/XXXX,
  // which oEmbed rejects with HTTP 400 — it only accepts the canonical
  // /@user/video/ID or /@user/photo/ID URL. Resolve the short link by
  // following its redirect chain, then strip query params, before calling
  // oEmbed. Skip the resolve step for URLs that already look canonical.
  let canonicalUrl = url;
  const needsResolve = url.includes('/t/');
  if (needsResolve) {
    try {
      canonicalUrl = await resolveRedirectUrl(url);
      console.log(`TikTok short link resolved: ${url} -> ${canonicalUrl}`);
    } catch (e) {
      console.warn(`Couldn't resolve TikTok short link, trying as-is: ${e.message}`);
    }
  }

  // Strip query params — TikTok appends tracking params that sometimes
  // confuse oEmbed even on canonical URLs.
  const cleanUrl = canonicalUrl.split('?')[0];

  // TikTok oEmbed only supports /video/ posts. /photo/ carousels return
  // HTTP 400 with no useful info. Instead of immediate failure, fetch the
  // post page, pull the og:image (which TikTok populates with the first
  // slide's image), and OCR it with Claude vision. Recipe-style photo
  // posts almost always put the ingredients/instructions on the first slide
  // as legible text, so this hits ~50-60% of cases. When OCR finds nothing
  // useful, fall through to the standard "try a screenshot" fallback.
  if (cleanUrl.includes('/photo/')) {
    console.log(`TikTok photo post — attempting og:image OCR fallback: ${cleanUrl}`);
    try {
      const html = await fetchUrl(cleanUrl);
      const ogImageMatch = html.match(
        /<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i,
      );
      if (!ogImageMatch) {
        console.log('No og:image found on TikTok photo page');
        return null;
      }
      const coverImageUrl = ogImageMatch[1].replace(/&amp;/g, '&');
      console.log(`Found cover image, calling vision OCR: ${coverImageUrl}`);
      const recipe = await extractRecipeFromImageWithAI(coverImageUrl, openaiKey);
      if (recipe && recipe.name && recipe.ingredients && recipe.ingredients.length > 0) {
        recipe.imageUrl = recipe.imageUrl || coverImageUrl;
        recipe.sourceUrl = url;
        console.log(`TikTok photo OCR succeeded: ${recipe.name} (${recipe.ingredients.length} ingredients)`);
        return recipe;
      }
      console.log('OCR returned no usable recipe from TikTok photo cover');
      return null;
    } catch (e) {
      console.error(`TikTok photo OCR failed: ${e.message}`);
      return null;
    }
  }

  const oembedUrl = `https://www.tiktok.com/oembed?url=${encodeURIComponent(cleanUrl)}`;
  console.log(`Calling TikTok oEmbed: ${oembedUrl}`);

  const raw = await fetchUrl(oembedUrl);
  let data;
  try {
    data = JSON.parse(raw);
  } catch (parseErr) {
    throw new Error(`TikTok oEmbed returned non-JSON response: ${parseErr.message}`);
  }

  // oEmbed `title` is the caption + author handle concatenated. That's the
  // recipe text we feed to the LLM. `author_name` and `thumbnail_url` are
  // used to decorate the result so the recipe card shows the creator + image.
  const caption = (data.title || '').trim();
  console.log(`TikTok caption length: ${caption.length} chars, author: ${data.author_name || 'unknown'}`);

  // Heuristic: under 50 chars, no recipe is plausibly encoded. Caller will
  // route to the screenshot path.
  if (caption.length < 50) {
    return null;
  }

  const recipe = await extractRecipeFromTextWithAI(caption, openaiKey);
  if (recipe) {
    recipe.imageUrl = recipe.imageUrl || data.thumbnail_url || '';
    recipe.sourceUrl = url;
    if (data.author_name) {
      recipe.source = data.author_name;
    }
  }
  return recipe;
}

async function extractRecipeFromTextWithAI(text, apiKey) {
  apiKey = apiKey.trim();
  console.log(`Extracting recipe from text with AI (length: ${text.length})`);

  const prompt = `Extract the recipe from this pasted text. Return ONLY valid JSON with this exact structure:
{
  "name": "Recipe Name",
  "description": "Brief description if available",
  "imageUrl": "",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", ...],
  "servings": "number of servings if mentioned",
  "prepTime": 15,
  "cookTime": 30,
  "confidence_flags": []
}

PASTED TEXT:
${text}

CRITICAL:
- Extract the recipe name from the text
- Parse all ingredients into separate array items
- Parse all instructions/steps into separate array items
- Each instruction should be ONE step only
- prepTime and cookTime must be integers in MINUTES. Use 0 if not mentioned.
- Return only valid JSON, no markdown formatting

${RECIPE_SPECIFICITY_RULES}`;

  const requestBody = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You are a recipe extraction assistant. Return only valid JSON, no markdown formatting.' },
      { role: 'user', content: prompt }
    ],
    temperature: 0.1,
    max_tokens: 2000
  });

  return new Promise((resolve, reject) => {
    const req = https.request('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      }
    }, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.error) {
            reject(new Error(`OpenAI API error: ${response.error.message}`));
            return;
          }

          const content = response.choices[0].message.content.trim();
          console.log(`AI response length: ${content.length}`);

          // Parse the JSON response
          const recipe = JSON.parse(content);
          resolve(recipe);
        } catch (parseError) {
          reject(new Error(`Failed to parse AI response: ${parseError.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(30000, () => {
      req.destroy();
      reject(new Error('AI extraction timeout'));
    });

    req.write(requestBody);
    req.end();
  });
}

// ── Grocery List Dedup / Normalization ───────────────
// One LLM pass that:
//   • collapses synonyms (flour + all-purpose flour -> one row)
//   • converts between compatible units (tbsp -> cup, oz -> lb) and sums
//   • picks the most-specific canonical form so Instacart matches the
//     right SKU (a generic "flour" matches everything, which is exactly
//     how we ended up ordering all-purpose flour twice — see Jun 2026 bug)
//   • flags items it can't confidently merge so the UI can show a "review"
//     badge instead of silently picking wrong
//
// Called at two points from the client:
//   1) grocery list build (after meal plan composes) — clean the list shown
//   2) Instacart submit — defensive re-run in case the user edited the list
//
// The function is idempotent on already-clean input — re-running won't
// shrink or rename rows that are already canonical.
//
// Request body: { items: [{ name, quantity, unit }, ...] }
// Response:    { items: [{ name, quantity, unit, needs_review, review_reason, merged_from }, ...] }
exports.dedupGroceryList = onRequest({ secrets: [openaiApiKey] }, async (request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (request.method === 'OPTIONS') { response.status(204).send(''); return; }
  if (request.method !== 'POST') {
    response.status(405).json({ result: { error: 'Method not allowed' } });
    return;
  }

  // Auth: match extractRecipe pattern.
  const authHeader = request.headers.authorization;
  let uid = null;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    try {
      const token = authHeader.split('Bearer ')[1];
      const decoded = await getAuth().verifyIdToken(token);
      uid = decoded.uid;
    } catch (e) {
      console.error('dedupGroceryList auth failed:', e.message);
    }
  }
  if (!uid) {
    response.status(401).json({ result: { error: 'Authentication required' } });
    return;
  }
  if (!checkRateLimit(uid)) {
    response.status(429).json({ result: { error: 'Rate limit exceeded. Try again later.' } });
    return;
  }

  const items = request.body?.data?.items;
  if (!Array.isArray(items)) {
    response.status(400).json({ result: { error: 'items must be an array' } });
    return;
  }
  if (items.length === 0) {
    response.json({ result: { items: [] } });
    return;
  }
  // Hard cap to keep latency + token cost bounded. A typical week's
  // grocery list is ~30 rows; anything above 80 is almost certainly a
  // client bug or attacker probe.
  if (items.length > 80) {
    response.status(400).json({ result: { error: 'too many items (max 80)' } });
    return;
  }

  try {
    const cleaned = await dedupGroceryListWithAI(items, openaiApiKey.value());
    response.json({ result: { items: cleaned } });
  } catch (e) {
    console.error('dedupGroceryList failed:', e.message);
    // Fail open: return original items unchanged so the user's flow isn't
    // blocked by an LLM hiccup. Better to ship an un-deduped list than
    // a 500.
    response.json({ result: { items, error: e.message } });
  }
});

async function dedupGroceryListWithAI(items, apiKey) {
  apiKey = (apiKey || '').trim();
  if (!apiKey) throw new Error('Missing OpenAI key');

  // Send only the structured fields. Stripping anything else (isChecked,
  // originalText) keeps the prompt focused and the JSON parse predictable.
  const compactItems = items.map((it, i) => ({
    i,
    name: String(it.name || '').trim(),
    quantity: typeof it.quantity === 'number' ? it.quantity : Number(it.quantity) || 0,
    unit: String(it.unit || '').trim(),
  })).filter((it) => it.name.length > 0);

  const systemPrompt = 'You are a grocery list deduplication assistant. You combine duplicate items (including synonyms like "flour" + "all-purpose flour"), convert between compatible cooking units to sum quantities, and pick the most shopper-specific canonical name for each grocery row. Return ONLY valid JSON, no prose.';

  const userPrompt = `Here is a grocery list. Each input row has an integer index, a name, a numeric quantity, and a unit string.

INPUT:
${JSON.stringify(compactItems)}

TASK:
1. Group rows that refer to the same SKU a shopper would buy. This includes synonyms and generic/specific variants:
   - "flour" + "all-purpose flour"  -> one row, name "all-purpose flour"
   - "sugar" + "granulated sugar"    -> one row, name "granulated sugar"
   - "butter" + "salted butter"      -> one row, name "salted butter"
   - "milk" + "whole milk"           -> one row, name "whole milk"
   - "egg" + "eggs" + "large eggs"   -> one row, name "large eggs"
   - "onion" + "yellow onion"        -> one row, name "yellow onion"
   - Different cheeses, different oils, different vinegars stay SEPARATE (cheddar != mozzarella, olive oil != vegetable oil). When in doubt, keep separate and flag.
2. For each group, sum quantities, converting compatible units (tsp/tbsp/cup, oz/lb, ml/L, g/kg). Pick the most natural display unit:
   - >= 4 tbsp of a dry good -> cups
   - >= 16 oz -> lb
   - >= 8 tbsp of butter -> sticks (1 stick = 8 tbsp)
   - small amounts of spice/extract -> teaspoons
   Round display quantities to nearest 1/4 unit when within 5%.
3. If two rows have incompatible units (one is "cup", another is "package"), keep them as ONE row but set needs_review=true with reason "incompatible units — please verify quantity".
4. If a row is too generic for confident Instacart matching (e.g. "cheese" with no type, "oil" with no type when cuisine is ambiguous), keep it as one row but set needs_review=true with a short reason.
5. needs_review=false unless flagged; review_reason omitted unless needs_review=true.
6. merged_from is the array of input indices that combined into this output row.

OUTPUT (return EXACTLY this JSON shape — an object with a single key "items"):
{
  "items": [
    {
      "name": "all-purpose flour",
      "quantity": 3.5,
      "unit": "cup",
      "needs_review": false,
      "merged_from": [0, 4]
    },
    {
      "name": "olive oil",
      "quantity": 2,
      "unit": "tablespoon",
      "needs_review": true,
      "review_reason": "couldn't determine if 'oil' meant olive — please confirm",
      "merged_from": [2]
    }
  ]
}

Rules:
- Preserve every input row in some output group. merged_from must cover all input indices exactly once across all output rows.
- Do not invent quantities. If an input row had quantity 0 and unit "", output quantity 0 and unit "".
- Names lowercase. Singular when possible ("large egg" not "large eggs" — UI handles pluralization).
- Be conservative on merges. If you're not sure two rows are the same SKU, keep separate.`;

  const requestBody = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    temperature: 0.1,
    max_tokens: 2000,
    response_format: { type: 'json_object' },
  });

  const raw = await new Promise((resolve, reject) => {
    const req = https.request('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'Content-Length': Buffer.byteLength(requestBody),
      },
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`OpenAI ${res.statusCode}: ${data.substring(0, 200)}`));
          return;
        }
        resolve(data);
      });
    });
    req.on('error', reject);
    req.setTimeout(20000, () => {
      req.destroy();
      reject(new Error('OpenAI timeout'));
    });
    req.write(requestBody);
    req.end();
  });

  const response = JSON.parse(raw);
  const content = response.choices?.[0]?.message?.content;
  if (!content) throw new Error('No content in OpenAI response');
  const parsed = JSON.parse(content);
  const out = Array.isArray(parsed.items) ? parsed.items : [];

  // Sanity-check: every input index should appear in some merged_from.
  // If the LLM dropped rows, append them as-is rather than losing them.
  const seen = new Set();
  for (const row of out) {
    for (const idx of (row.merged_from || [])) seen.add(idx);
  }
  const missing = compactItems.filter((it) => !seen.has(it.i));
  if (missing.length > 0) {
    console.warn(`dedupGroceryList: LLM dropped ${missing.length} rows; appending as-is.`);
    for (const m of missing) {
      out.push({
        name: m.name,
        quantity: m.quantity,
        unit: m.unit,
        needs_review: true,
        review_reason: 'lost during dedup — please verify',
        merged_from: [m.i],
      });
    }
  }
  return out;
}

// ── Stripe Subscription Functions ───────────────────
const stripeFunctions = require('./stripe_functions');
exports.createSubscription = stripeFunctions.createSubscription;
exports.cancelSubscription = stripeFunctions.cancelSubscription;
exports.restorePurchases = stripeFunctions.restorePurchases;
exports.stripeWebhook = stripeFunctions.stripeWebhook;

// Apple App Store Server Notifications V2 — the iOS twin of stripeWebhook.
// Credits creator_earnings on iOS subscription / renewal / refund events.
const appleIapFunctions = require('./apple_iap_functions');
exports.appleNotification = appleIapFunctions.appleNotification;

// "Poor man's Branch" — self-hosted deferred deep linking. Web /c/{code}
// page POSTs a device fingerprint to recordPendingAttribution; the app
// claims the match on first launch via claimAttribution. See
// creator_attribution_match.js for the design rationale.
const creatorAttributionMatch = require('./creator_attribution_match');
exports.recordPendingAttribution = creatorAttributionMatch.recordPendingAttribution;
exports.claimAttribution = creatorAttributionMatch.claimAttribution;

// Email a creator every time a new earning lands in their ledger.
// Sandbox + clawback rows are filtered out at the trigger level.
const creatorNotifications = require('./creator_notifications');
const creatorPlanSync = require('./creator_plan_sync');
const feedbackMd = require('./feedback_md');
exports.notifyOnCreatorEarning = creatorNotifications.notifyOnCreatorEarning;
exports.notifyOnCreatorPayout = creatorNotifications.notifyOnCreatorPayout;
exports.notifyFollowersOnPublish = creatorNotifications.notifyFollowersOnPublish;
exports.unsubscribeCreatorEmails = creatorNotifications.unsubscribeCreatorEmails;
exports.syncCreatorPlanToContent = creatorPlanSync.syncCreatorPlanToContent;
exports.backfillCreatorPlans = creatorPlanSync.backfillCreatorPlans;

const pinterestAutopin = require('./pinterest_autopin');
exports.pinterestAutoPin = pinterestAutopin.pinterestAutoPin;
exports.pinterestTestPin = pinterestAutopin.pinterestTestPin;
exports.feedbackMarkdown = feedbackMd.feedbackMarkdown;
exports.createCreatorOnboardingLink = stripeFunctions.createCreatorOnboardingLink;
exports.createCreatorDashboardLink = stripeFunctions.createCreatorDashboardLink;
exports.getCreatorConnectStatus = stripeFunctions.getCreatorConnectStatus;
exports.runCreatorPayouts = stripeFunctions.runCreatorPayouts;

// ── Notification Scheduling ─────────────────────────
// Writes a reminder doc; processReminders cron picks it up and sends
// the FCM push when `time` arrives.
exports.scahdulNotification = onCall(async (request) => {
  const { token, time } = request.data || {};

  if (!token || !time) {
    throw new HttpsError('invalid-argument', 'token and time are required');
  }

  const scheduledTime = new Date(time);
  if (isNaN(scheduledTime.getTime())) {
    throw new HttpsError('invalid-argument', 'time must be a valid date');
  }
  if (scheduledTime <= new Date()) {
    throw new HttpsError('invalid-argument', 'time must be in the future');
  }

  await getFirestore().collection('reminders').add({
    token,
    time: scheduledTime,
    sent: false,
  });

  return '✅ Reminder scheduled';
});

// ── User-triggered cleanup ──────────────────────────
// Deletes all of a user's recipes (meal), saved days (favourit_meal),
// and meal templates (meal_combo). Scoped to the authenticated uid.
exports.cleanupUnlabeledContent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated to clean up content.');
  }

  const userId = request.auth.uid;
  const db = getFirestore();
  const userDocRef = db.doc(`users/${userId}`);
  const results = { recipesDeleted: 0, savedDaysDeleted: 0, templatesDeleted: 0 };

  try {
    const [recipesSnap, savedDaysSnap, templatesSnap] = await Promise.all([
      db.collection('meal').where('user_ref', '==', userDocRef).get(),
      db.collection('favourit_meal').where('user_ref', '==', userDocRef).get(),
      db.collection('meal_combo').where('user_ref', '==', userDocRef).get(),
    ]);

    const deletes = [];
    recipesSnap.forEach((doc) => { deletes.push(doc.ref.delete()); results.recipesDeleted++; });
    savedDaysSnap.forEach((doc) => { deletes.push(doc.ref.delete()); results.savedDaysDeleted++; });
    templatesSnap.forEach((doc) => { deletes.push(doc.ref.delete()); results.templatesDeleted++; });

    await Promise.all(deletes);

    console.log(`Cleanup complete for user ${userId}:`, results);
    return {
      success: true,
      ...results,
      message: `Deleted ${results.recipesDeleted} recipes, ${results.savedDaysDeleted} saved days, and ${results.templatesDeleted} templates.`,
    };
  } catch (error) {
    console.error('Error during cleanup:', error);
    throw new HttpsError('internal', error.message);
  }
});

// ── Reminder Dispatcher (every 1 min) ───────────────
// Reads due reminders from Firestore and fires FCM pushes.
exports.processReminders = onSchedule(
  { schedule: 'every 1 minutes', timeZone: 'Africa/Cairo' },
  async () => {
    const now = new Date();
    const db = getFirestore();
    const snapshot = await db.collection('reminders')
      .where('time', '<=', now)
      .where('sent', '==', false)
      .get();

    if (snapshot.empty) {
      console.log('No reminders to send');
      return;
    }

    console.log('Reminders to send:', snapshot.docs.map((d) => d.id));

    await Promise.all(snapshot.docs.map(async (doc) => {
      const reminder = doc.data();
      if (!reminder.token) {
        console.warn(`Reminder ${doc.id} has no token`);
        return;
      }
      const payload = {
        notification: {
          title: 'Meal Planner 🍴',
          body: "Don't forget to plan your meals today!",
        },
        token: reminder.token,
      };
      try {
        await getMessaging().send(payload);
        await doc.ref.update({ sent: true });
        console.log(`Reminder ${doc.id} sent ✅`);
      } catch (error) {
        console.error(`Error sending reminder ${doc.id}:`, error);
      }
    }));
  }
);

// ── User cleanup on Firebase Auth delete ────────────
// v1 API (Firebase Functions v2 has no auth onDelete trigger yet).
// Still runs on Node 22 because engines.node in package.json controls
// runtime for both v1 and v2 functions in this codebase.
const functionsV1 = require('firebase-functions/v1');

exports.onUserDeleted = functionsV1.auth.user().onDelete(async (user) => {
  await getFirestore().collection('users').doc(user.uid).delete();
  console.log(`Deleted user doc for uid ${user.uid}`);
});

// ── Meal tag verifier (Firestore onCreate) ──────────
// Safety net: if a newly-created meal doc has no mealTyp, auto-detect
// the category from the recipe name keywords.
const MEAL_CATEGORY_KEYWORDS = {
  Breakfast: ['breakfast','pancake','waffle','oatmeal','cereal','toast','eggs','bacon','sausage','brunch','muffin','bagel','croissant','french toast','scrambled','omelet','smoothie bowl'],
  Lunch: ['lunch','sandwich','wrap','salad','soup','panini','burger','sub','hoagie'],
  Dinner: ['dinner','roast','steak','chicken breast','pork chop','salmon','pasta','casserole','curry','stir fry','grilled','baked chicken','pot roast','lasagna','enchilada','risotto'],
  Side: ['side','sides','side dish','fries','mashed potato','coleslaw','green beans','corn','rice','roasted vegetables'],
  Snacks: ['snack','appetizer','dip','chip','cracker','finger food','bite','ball'],
  Desserts: ['dessert','cake','cookie','brownie','pie','ice cream','chocolate','sweet','pudding','tart','cupcake','cheesecake','candy','fudge','truffle'],
};

exports.verifyMealTags = onDocumentCreated('meal/{mealId}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  const mealData = snap.data();
  const mealTyp = mealData.mealTyp;
  const mealId = event.params.mealId;

  if (mealTyp && mealTyp.trim().length > 0) {
    console.log(`Meal ${mealId} already has mealTyp: ${mealTyp}`);
    return;
  }

  console.log(`Meal ${mealId} missing mealTyp, auto-detecting...`);

  const recipeName = (mealData.recipeName || '').toLowerCase();
  const detected = [];
  for (const [category, keywords] of Object.entries(MEAL_CATEGORY_KEYWORDS)) {
    if (keywords.some((kw) => recipeName.includes(kw))) detected.push(category);
  }

  if (detected.length === 0) {
    detected.push('Dinner');
    console.log(`No keywords matched for "${recipeName}", defaulting to Dinner`);
  }

  const newMealTyp = detected.join(',');
  console.log(`Auto-detected categories for meal ${mealId}: ${newMealTyp}`);

  try {
    await snap.ref.update({ mealTyp: newMealTyp });
    console.log(`Successfully updated meal ${mealId} with mealTyp: ${newMealTyp}`);
  } catch (error) {
    console.error(`Error updating meal ${mealId}:`, error);
  }
});

// ── AI-generated child learning programs (OpenAI Assistants) ─
// Takes a challenge description, drives an OpenAI Assistant, and
// creates a program + spaced tasks in Firestore.
const OpenAI = require('openai');
const moment = require('moment-timezone');
const CHILD_TASKS_ASSISTANT_ID = 'asst_Zrdo4Vh9j6BeaRALEXyqPZMZ';

exports.generateChildTasks = onCall(
  { secrets: [openaiApiKey], timeoutSeconds: 180, memory: '512MiB' },
  async (request) => {
    try {
      const data = request.data || {};
      console.log('Received request:', data);

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

      if (!challengeDescription || !childBirthDate || !currentDate ||
          !parentId || !childId || !frequency || !preferredTime || !timezone) {
        console.warn('Missing required fields', data);
        throw new HttpsError('invalid-argument', 'Missing required fields');
      }

      const openai = new OpenAI({ apiKey: openaiApiKey.value().trim() });
      const db = getFirestore();

      console.log('Creating a thread with OpenAI Assistant');
      const thread = await openai.beta.threads.create();
      console.log('Thread created:', thread.id);

      await openai.beta.threads.messages.create(thread.id, {
        role: 'user',
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
      console.log('Message sent to assistant');

      const run = await openai.beta.threads.runs.create(thread.id, {
        assistant_id: CHILD_TASKS_ASSISTANT_ID,
      });
      console.log('Assistant run started:', run.id);

      let runStatus;
      do {
        runStatus = await openai.beta.threads.runs.retrieve(thread.id, run.id);
        console.log('Run status:', runStatus.status);
        await new Promise((r) => setTimeout(r, 2000));
      } while (runStatus.status !== 'completed');

      const messages = await openai.beta.threads.messages.list(thread.id);
      const responseMessage = messages.data.find((m) => m.role === 'assistant');

      let responseData = null;
      if (responseMessage && responseMessage.content && responseMessage.content.length > 0) {
        const textBlock = responseMessage.content.find((c) => c.type === 'text');
        if (textBlock) {
          let rawText = textBlock.text.value;
          console.log('Assistant raw text:', rawText);
          rawText = rawText.replace(/```json|```/g, '').trim();
          try {
            responseData = JSON.parse(rawText);
          } catch (e) {
            console.error('JSON parse error. Raw text was:', rawText);
            throw new HttpsError('internal', 'Assistant did not return valid JSON');
          }
        }
      }

      if (!responseData) {
        throw new HttpsError('internal', 'Invalid response from OpenAI');
      }
      if (!responseData.programe_title || !responseData.programe_description ||
          !Array.isArray(responseData.tasks)) {
        console.error('Assistant response missing required fields:', responseData);
        throw new HttpsError('internal', 'Assistant response missing required fields');
      }

      let startDate = moment.tz(currentDate, 'YYYY-MM-DD HH:mm:ss.SSS', timezone);
      const now = moment.tz(timezone);

      const timeFormat = preferredTime.includes('AM') || preferredTime.includes('PM')
        ? 'YYYY-MM-DD hh:mm A'
        : 'YYYY-MM-DD HH:mm';
      const preferredStartTime = moment.tz(
        `${startDate.format('YYYY-MM-DD')} ${preferredTime}`,
        timeFormat,
        timezone
      );
      if (now.isAfter(preferredStartTime)) {
        startDate.add(1, 'day');
      }

      const firestoreStartDate = Timestamp.fromDate(startDate.toDate());

      const programRef = await db.collection('programs').add({
        title: responseData.programe_title,
        description: responseData.programe_description,
        created_at: Timestamp.now(),
        created_by: db.collection('users').doc(parentId),
        start_date: firestoreStartDate,
        end_date: null,
        tasks: [],
      });
      console.log('Program created with ID:', programRef.id);

      const taskRefs = [];
      const taskDates = [];
      let taskDate = startDate.clone();
      let endDate = startDate.clone();

      for (const task of responseData.tasks) {
        const taskStartTime = moment
          .tz(`${taskDate.format('DD-MM-YYYY')} ${preferredTime}`, 'DD-MM-YYYY HH:mm', timezone)
          .toDate();
        const taskDateString = taskDate.format('DD-MM-YYYY');

        const taskRef = await db.collection('tasks').add({
          title: task.title,
          description: task.description,
          duration: task.duration,
          created_by: db.collection('users').doc(parentId),
          selected_child: db.collection('children').doc(childId),
          program_id: programRef,
          task_date: taskDateString,
          task_start_time: Timestamp.fromDate(taskStartTime),
        });

        taskRefs.push(taskRef);
        taskDates.push(Timestamp.fromDate(taskStartTime));
        taskDate.add(frequency, 'days');
        endDate = taskDate.clone();
      }

      await programRef.update({
        tasks: taskRefs,
        end_date: Timestamp.fromDate(endDate.toDate()),
        task_dates: taskDates,
      });

      return {
        message: 'Program and tasks created successfully',
        programId: programRef.id,
      };
    } catch (error) {
      console.error('Error processing request:', error);
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', error.message || 'Internal server error');
    }
  }
);

// ── Cookbook Scanner (Claude Vision) ────────────────
// HTTP endpoint: Flutter posts { imageBase64 } or { imageUrl }, gets
// back a structured recipe extracted via Claude Sonnet.
exports.scanCookbookWithClaude = onRequest(
  { secrets: [anthropicApiKey], timeoutSeconds: 120, memory: '512MiB' },
  async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      const data = req.body.data || req.body;
      let imageBase64 = data.imageBase64;
      const imageUrl = data.imageUrl;

      if (imageUrl && !imageBase64) {
        try {
          imageBase64 = await new Promise((resolve, reject) => {
            https.get(imageUrl, (response) => {
              const chunks = [];
              response.on('data', (c) => chunks.push(c));
              response.on('end', () => resolve(Buffer.concat(chunks).toString('base64')));
              response.on('error', reject);
            }).on('error', reject);
          });
        } catch (err) {
          console.error('Failed to fetch image from URL:', err.message);
          res.status(400).json({ result: { success: false, error: 'Could not fetch image from URL' } });
          return;
        }
      }

      if (!imageBase64) {
        res.status(400).json({ result: { success: false, error: 'No image provided' } });
        return;
      }

      // Detect the actual image type from the base64 magic-byte prefix.
      // The media_type sent to Claude must match the real bytes — the
      // mobile camera always shoots JPEG, but web uploads can be PNG /
      // GIF / WebP, and a mismatch makes Claude reject with HTTP 400.
      let mediaType;
      if (imageBase64.startsWith('/9j/')) mediaType = 'image/jpeg';
      else if (imageBase64.startsWith('iVBORw0KGgo')) mediaType = 'image/png';
      else if (imageBase64.startsWith('R0lGOD')) mediaType = 'image/gif';
      else if (imageBase64.startsWith('UklGR')) mediaType = 'image/webp';
      else {
        // Unknown / unsupported format (e.g. HEIC from an iPhone). Claude
        // only accepts jpeg/png/gif/webp — fail with a clear message.
        res.status(400).json({
          result: {
            success: false,
            error: "That image format isn't supported. Use a JPG, PNG, or WebP — or take a screenshot of the recipe and upload that.",
          },
        });
        return;
      }

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

      const reqBody = JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2048,
        messages: [{
          role: 'user',
          content: [
            { type: 'image', source: { type: 'base64', media_type: mediaType, data: imageBase64 } },
            { type: 'text', text: prompt },
          ],
        }],
      });

      const responseText = await new Promise((resolve, reject) => {
        const r = https.request('https://api.anthropic.com/v1/messages', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': anthropicApiKey.value().trim(),
            'anthropic-version': '2023-06-01',
            'Content-Length': Buffer.byteLength(reqBody),
          },
        }, (ar) => {
          let buf = '';
          ar.on('data', (c) => { buf += c; });
          ar.on('end', () => {
            if (ar.statusCode !== 200) {
              reject(new Error(`Anthropic HTTP ${ar.statusCode}: ${buf.substring(0, 200)}`));
              return;
            }
            try {
              const parsed = JSON.parse(buf);
              const text = parsed?.content?.[0]?.text ?? '';
              resolve(text);
            } catch (e) {
              reject(new Error(`Parse Anthropic response: ${e.message}`));
            }
          });
        });
        r.on('error', reject);
        r.setTimeout(110000, () => { r.destroy(); reject(new Error('Anthropic timeout')); });
        r.write(reqBody);
        r.end();
      });

      let cleaned = responseText.trim();
      if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
      else if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
      if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
      cleaned = cleaned.trim();

      const recipe = JSON.parse(cleaned);
      if (recipe.error) {
        res.status(200).json({ result: { success: false, error: recipe.error } });
        return;
      }
      res.status(200).json({ result: { success: true, recipe } });
    } catch (error) {
      console.error('Error scanning cookbook:', error);
      res.status(500).json({ result: { success: false, error: error.message || 'Failed to extract recipe' } });
    }
  }
);

// ── Daily Recurring Task Generator (5am Paris) ──────
// For each recurring event_and_task, creates a fresh instance for today
// preserving the original hour/minute.
exports.generateDailyRecurringTasks = onSchedule(
  { schedule: '0 5 * * *', timeZone: 'Europe/Paris' },
  async () => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    console.log('🚀 Running recurring task generator for:', today.toISOString());
    const db = getFirestore();

    try {
      const snapshot = await db.collection('event_and_task')
        .where('isrecurring', '==', true)
        .get();

      if (snapshot.empty) {
        console.log('⚠️ No recurring tasks found');
        return;
      }

      for (const doc of snapshot.docs) {
        const task = doc.data();

        const lastGenerated = task.lastGenerated instanceof Timestamp
          ? task.lastGenerated.toDate()
          : task.lastGenerated ? new Date(task.lastGenerated) : null;

        const originalDate = task.date instanceof Timestamp
          ? task.date.toDate()
          : task.date ? new Date(task.date) : null;

        if (!originalDate) {
          console.warn(`⚠️ Skipping ${doc.id}: invalid date`);
          continue;
        }

        if (!lastGenerated || lastGenerated < today) {
          const newDate = new Date();
          newDate.setHours(originalDate.getHours(), originalDate.getMinutes(), 0, 0);

          await db.collection('event_and_task').add({
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
      console.error('🔥 Error generating recurring tasks:', error);
    }
  }
);

// ── Creator follower + subscriber counters ────────────
// The creator dashboard can't list users by active_creator_code (users docs
// are owner-only read), so we denormalize the counts onto creators/{id}.
// Triggered on every user doc write.
//   follower_count:  any user with active_creator_code set
//   subscriber_count: users with active_creator_code AND active subscription
async function _adjustCreatorCounter(code, field, delta) {
  if (!code) return;
  const db = getFirestore();
  const snap = await db.collection('creators').where('code', '==', code).limit(1).get();
  if (snap.empty) return;
  const ref = snap.docs[0].ref;
  // Transactional floor at 0. Plain FieldValue.increment(-1) drifts negative
  // when the creator was created after a follower already had the code set
  // (the +1 never fired but -1 fires on unfollow), and there's no way to
  // express "max(0, x + delta)" as a single increment op.
  await db.runTransaction(async (tx) => {
    const cur = await tx.get(ref);
    const next = Math.max(0, (cur.get(field) || 0) + delta);
    tx.update(ref, { [field]: next });
  });
}

function _isActiveSub(data) {
  if (!data) return false;
  const status = data.subscription_status;
  return status === 'active' || status === 'trialing';
}

// ── Notify admin on new creator application ──────────
// Fires when someone submits /apply/. Emails collinjmaddox@gmail.com
// with a summary so pending applications don't rot unseen in Firestore.
exports.notifyOnCreatorApplication = onDocumentCreated(
  {
    document: 'creator_applications/{appId}',
    secrets: [sendgridApiKey],
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    try {
      sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
      const appId = snap.id;
      const esc = (s) => String(s || '').replace(/[<>&]/g, c => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]));

      const row = (label, value) =>
        `<tr>
          <td style="padding: 10px 14px; border-bottom: 1px solid #F3F4F6; color: #6B7280; font-size: 13px; font-weight: 500; vertical-align: top; width: 120px; text-transform: uppercase; letter-spacing: 0.04em;">${label}</td>
          <td style="padding: 10px 14px; border-bottom: 1px solid #F3F4F6; color: #1F2937; font-size: 15px;">${value}</td>
        </tr>`;

      await sgMail.send({
        to: 'collinjmaddox@gmail.com',
        from: sendgridFromEmail.value(),
        subject: `New creator application: ${d.name || '(no name)'}`,
        trackingSettings: {
          clickTracking: { enable: false, enableText: false },
          openTracking: { enable: false },
        },
        html: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB; line-height: 1.6;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">

    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 28px 32px; color: white;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.85; margin-bottom: 4px;">MomRise Creator Program</div>
      <h1 style="margin: 0; font-size: 22px; font-weight: 700;">New creator application</h1>
      <div style="margin-top: 6px; font-size: 14px; opacity: 0.9;">${esc(d.name)} · ${esc(d.primary_handle)}</div>
    </div>

    <div style="padding: 24px 32px 12px;">
      <table style="width: 100%; border-collapse: collapse;">
        ${row('Name', esc(d.name))}
        ${row('Email', `<a href="mailto:${esc(d.email)}" style="color: #52A097; text-decoration: none;">${esc(d.email)}</a>`)}
        ${row('Handle', esc(d.primary_handle))}
        ${d.other_handles ? row('Other', esc(d.other_handles)) : ''}
        ${row('Audience', esc(d.audience_size))}
        ${row('Website', d.website ? `<a href="${esc(d.website)}" style="color: #52A097; text-decoration: none;">${esc(d.website)}</a>` : '<span style="color: #9CA3AF;">(none)</span>')}
        ${row('Community', esc(d.audience_description))}
        ${row('Pitch', `<div style="white-space: pre-wrap;">${esc(d.pitch)}</div>`)}
      </table>
    </div>

    <div style="padding: 4px 32px 28px; text-align: center;">
      <a href="https://momrise.app/admin/?app=${appId}"
         style="display: inline-block; background: #52A097; color: white !important; text-decoration: none; padding: 14px 32px; border-radius: 10px; font-weight: 600; font-size: 15px;">
        Review in admin dashboard →
      </a>
    </div>

    <div style="background: #F9FAFB; padding: 16px 32px; text-align: center; color: #9CA3AF; font-size: 12px; border-top: 1px solid #E5E7EB;">
      Application ID: <span style="font-family: monospace; color: #6B7280;">${appId}</span>
    </div>
  </div>
</body>
</html>`,
      });
      console.log(`Sent creator-application notification for ${appId}`);
    } catch (err) {
      console.error('Failed to send creator-application notification:', err.message);
      if (err.response?.body) {
        console.error('SendGrid response body:', JSON.stringify(err.response.body));
      }
      console.error('SendGrid response code:', err.code || err.response?.statusCode);
    }
  }
);

// ── Admin: approve / reject creator applications ─────
// Called by the /admin/ dashboard. Gated on the caller's email.
// Approve creates the creator doc (same logic as admin/approve-creator.js)
// and marks the application approved. Reject just flips the status.
const ADMIN_EMAILS = ['collinjmaddox@gmail.com', 'brennanmaddox27@gmail.com', 'haley.hostetter@gmail.com'];

function _requireAdmin(request) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const email = (request.auth.token?.email || '').toLowerCase();
  if (!ADMIN_EMAILS.includes(email)) {
    throw new HttpsError('permission-denied', 'Admin access required');
  }
}

async function _generateUniqueCreatorCode(baseName) {
  const db = getFirestore();
  const clean = (baseName || 'CREATOR').replace(/[^A-Za-z]/g, '').toUpperCase();
  const stem = (clean.slice(0, 5) || 'MOM').padEnd(3, 'X');
  for (let i = 0; i < 25; i++) {
    const suffix = String(Math.floor(Math.random() * 90) + 10);
    const candidate = `${stem}${suffix}`;
    const existing = await db.collection('creators').where('code', '==', candidate).limit(1).get();
    if (existing.empty) return candidate;
  }
  throw new HttpsError('internal', 'Could not generate a unique code');
}

// Admin: comp an email to lifetime free premium (mirrors admin/add-to-exempt.js).
// Called by the /admin/ dashboard so exemptions no longer need a downloaded
// service-account key. Gated on the caller's admin email.
exports.adminAddPremiumExempt = onCall(async (request) => {
  _requireAdmin(request);
  const rawEmail = String(request.data?.email || '').trim();
  const email = rawEmail.toLowerCase();
  if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    throw new HttpsError('invalid-argument', 'A valid email is required');
  }

  const db = getFirestore();
  const auth = getAuth();

  // 1. Write the exempt doc — activates on the user's next sign-in even if
  //    they don't have an account yet.
  await db.collection('premium_exempt').doc(email).set({
    added_at: FieldValue.serverTimestamp(),
    added_by: request.auth.token?.email || 'admin-dashboard',
    source_email: rawEmail,
  });

  // 2. If they already have an Auth account, flip their subscription now.
  let flipped = false;
  try {
    const user = await auth.getUserByEmail(email);
    await db.collection('users').doc(user.uid).set(
      {
        subscription_status: 'active',
        subscription_source: 'exempt',
        subscription_plan: 'lifetime_exempt',
        subscription_updated_at: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    flipped = true;
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
  }

  return {
    ok: true,
    email,
    flipped,
    message: flipped
      ? 'Premium unlocked — active on their next sign-in.'
      : 'Exemption saved — activates when they first sign in.',
  };
});

// Admin: remove an email's premium-exempt status (mirrors remove-from-exempt.js).
exports.adminRemovePremiumExempt = onCall(async (request) => {
  _requireAdmin(request);
  const email = String(request.data?.email || '').trim().toLowerCase();
  if (!email) throw new HttpsError('invalid-argument', 'A valid email is required');

  const db = getFirestore();
  const auth = getAuth();

  await db.collection('premium_exempt').doc(email).delete();

  // If they have an account and are currently exempt, clear it back to free.
  try {
    const user = await auth.getUserByEmail(email);
    const userRef = db.collection('users').doc(user.uid);
    const snap = await userRef.get();
    if (snap.exists && snap.data()?.subscription_source === 'exempt') {
      await userRef.set(
        {
          subscription_status: 'inactive',
          subscription_source: 'none',
          subscription_updated_at: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
  }

  return { ok: true, email };
});

// Public creator profile lookup (unauthenticated) — powers /c/{CODE} pages.
// Returns only safe, public fields; never Stripe IDs or earnings.
exports.getPublicCreatorProfile = onRequest({ cors: true }, async (request, response) => {
  try {
    const code = String(request.query.code || '').trim().toUpperCase();
    if (!/^[A-Z0-9]{3,20}$/.test(code)) {
      response.status(400).json({ error: 'invalid code' });
      return;
    }
    const db = getFirestore();
    const snap = await db.collection('creators')
      .where('code', '==', code).limit(1).get();
    if (snap.empty) {
      response.status(404).json({ error: 'not found' });
      return;
    }
    const c = snap.docs[0].data();
    if (c.is_active === false) {
      response.status(404).json({ error: 'not found' });
      return;
    }
    response.set('Cache-Control', 'public, max-age=60, s-maxage=300');
    response.json({
      code: c.code,
      name: c.name || null,
      bio: c.bio || null,
      niche: c.niche || null,
      photo_url: c.photo_url || null,
      theme_primary: c.theme_primary_color || c.theme_primary || null,
      follower_count: c.follower_count || 0,
    });
  } catch (e) {
    console.error('getPublicCreatorProfile failed', e);
    response.status(500).json({ error: 'server error' });
  }
});

exports.approveCreatorApplication = onCall(
  { secrets: [sendgridApiKey] },
  async (request) => {
  _requireAdmin(request);
  const { applicationId, uid: providedUid, overwriteExisting } = request.data || {};
  if (!applicationId) throw new HttpsError('invalid-argument', 'applicationId required');

  const db = getFirestore();
  const auth = getAuth();
  const appRef = db.collection('creator_applications').doc(applicationId);
  const appSnap = await appRef.get();
  if (!appSnap.exists) throw new HttpsError('not-found', 'Application not found');
  const appData = appSnap.data();

  // Resolve user uid by submitted email, fall back to caller-provided.
  let uid = providedUid;
  if (!uid) {
    try {
      const userRec = await auth.getUserByEmail(appData.email);
      uid = userRec.uid;
    } catch (err) {
      if (err.code === 'auth/user-not-found') {
        throw new HttpsError('failed-precondition',
          `No Firebase user with email ${appData.email}. Ask them to sign up in the app, then retry with their UID.`);
      }
      throw err;
    }
  }

  // Sanity-verify uid exists.
  try { await auth.getUser(uid); }
  catch (err) { throw new HttpsError('failed-precondition', `Could not verify uid ${uid}: ${err.message}`); }

  // Check for existing creator doc linked to this user.
  const existing = await db.collection('creators')
    .where('user_ref', '==', db.doc(`users/${uid}`))
    .limit(1).get();
  if (!existing.empty) {
    const exDoc = existing.docs[0];
    const exData = exDoc.data();
    if (overwriteExisting === true) {
      // Admin chose "delete and retry" — also clean up the old
      // creator's earnings + snapshots subcollection so stats don't leak.
      console.log(`Overwriting existing creator ${exDoc.id} (code ${exData.code || '(none)'}) per admin request`);
      const earningsSnap = await db.collection('creator_earnings')
        .where('creator_ref', '==', exDoc.ref).get();
      const snapshotsSnap = await exDoc.ref.collection('snapshots').get();
      const delBatch = db.batch();
      earningsSnap.forEach(d => delBatch.delete(d.ref));
      snapshotsSnap.forEach(d => delBatch.delete(d.ref));
      delBatch.delete(exDoc.ref);
      await delBatch.commit();
    } else {
      throw new HttpsError(
        'already-exists',
        `This user already has a creator profile (code ${exData.code || '(not set)'}).`,
        { existingCreatorId: exDoc.id, existingCode: exData.code || null }
      );
    }
  }

  const creatorRef = db.collection('creators').doc();
  const batch = db.batch();
  batch.set(creatorRef, {
    name: appData.name,
    code: '', // Creator picks their own code on first sign-in.
    user_ref: db.doc(`users/${uid}`),
    is_active: true,
    country: (appData.country && appData.country !== 'OTHER') ? appData.country : 'US',
    bio: appData.audience_description || '',
    niche: appData.audience_description || '',
    avatar_url: '',
    follower_count: 0,
    subscriber_count: 0,
    lifetime_payout_cents: 0,
    theme_primary: '#52A097',
    theme_secondary: '#D7F2EB',
    theme_accent: '#EE8B60',
    theme_font: '',
    theme_font_url: '',
    stripe_connect_onboarded: false,
    created_at: FieldValue.serverTimestamp(),
    approved_from_application: appRef,
  });
  batch.update(appRef, {
    status: 'approved',
    approved_at: FieldValue.serverTimestamp(),
    approved_creator_ref: creatorRef,
    assigned_uid: uid,
    approved_by: request.auth.token.email,
  });
  // Every approved creator gets MomRise free forever. We set their
  // users doc to "active" with a comp source so the existing paywall
  // check (hasActiveSubscription → status in {trialing, active}) passes
  // without any app changes. If they ever also buy a Stripe sub the
  // webhook will overwrite these fields and that's fine — they keep access.
  const userRef = db.doc(`users/${uid}`);
  batch.set(userRef, {
    is_comped: true,
    subscription_source: 'creator_comp',
    subscription_status: 'active',
    current_period_end: new Date('2099-12-31T00:00:00Z'),
    comped_at: FieldValue.serverTimestamp(),
    comped_by: request.auth.token.email,
    comped_reason: 'creator_program',
  }, { merge: true });
  await batch.commit();

  // Send the welcome email. Don't fail the whole approval if email fails —
  // log it and return success anyway so the admin doesn't retry approval
  // (which would error with "already exists" on the creator doc).
  try {
    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
    await sgMail.send({
      to: appData.email,
      from: sendgridFromEmail.value(),
      subject: `You're in — welcome to the MomRise creator program 🎉`,
      trackingSettings: {
        clickTracking: { enable: false, enableText: false },
        openTracking: { enable: false },
      },
      html: _renderCreatorWelcomeEmail(appData.name),
    });
    console.log(`Sent creator welcome email to ${appData.email}`);
  } catch (err) {
    console.error('Welcome email send failed (creator doc still created):', err.message);
    if (err.response?.body) console.error('SendGrid body:', JSON.stringify(err.response.body));
  }

  return { ok: true, creatorId: creatorRef.id };
});

function _renderCreatorWelcomeEmail(name) {
  const first = (name || '').split(' ')[0] || 'there';
  return `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB; line-height: 1.6;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 40px 32px; color: white; text-align: center;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85; margin-bottom: 8px;">MomRise Creator Program</div>
      <h1 style="margin: 0; font-size: 26px; font-weight: 700;">You're in, ${_esc(first)} 🎉</h1>
    </div>
    <div style="padding: 32px; color: #374151; font-size: 15px;">
      <p style="margin: 0 0 16px;">Welcome to the MomRise creator program. We reviewed your application and would love to have you on board.</p>

      <p style="margin: 20px 0 8px; font-weight: 600; color: #1F2937;">What to do next:</p>
      <ol style="padding-left: 20px; margin: 0 0 20px;">
        <li style="margin: 10px 0;"><strong>Need a MomRise account first?</strong> If you haven't signed up for MomRise yet, <a href="https://momrise.app/" style="color: #52A097;">grab the app</a> and create an account with this same email. Takes 30 seconds.</li>
        <li style="margin: 10px 0;">Sign in at <a href="https://momrise.app/creator/" style="color: #52A097;">momrise.app/creator/</a> with the same email you used on your application. Your dashboard will load automatically.</li>
        <li style="margin: 10px 0;"><strong>Pick your creator code.</strong> On first sign-in you'll choose a code (3–20 letters or numbers) — this is what your community enters to earn you a share of their subscriptions. Pick something memorable.</li>
        <li style="margin: 10px 0;"><strong>Connect your bank through Stripe</strong> (2–3 minutes). That's how we pay you your revenue share.</li>
        <li style="margin: 10px 0;">Start sharing your code with your community — our <a href="https://momrise.app/creator/playbook/" style="color: #52A097;">creator playbook</a> covers exactly what works (and what doesn't) for promoting parenting apps. Read it before your first post.</li>
      </ol>

      <p style="margin: 24px 0 8px;"><strong>You get paid when we get paid.</strong> Apple holds each month's subscription revenue for about a month before depositing it to MomRise — once it lands, your share goes out on the next monthly payout run ($25 minimum). Your dashboard always shows your balance and the exact date it pays out, so you never have to guess.</p>
      <p style="margin: 16px 0 8px;">Everything else (follower count, earnings, content performance) is in your dashboard too.</p>

      <div style="text-align: center; margin: 32px 0 16px;">
        <a href="https://momrise.app/creator/" style="display: inline-block; background: #52A097; color: white !important; text-decoration: none; padding: 14px 36px; border-radius: 10px; font-weight: 600; font-size: 15px;">Go to your dashboard →</a>
      </div>

      <p style="margin: 24px 0 0; color: #6B7280; font-size: 14px;">Questions or ideas? Just reply to this email — we read everything.</p>
    </div>
    <div style="background: #F9FAFB; padding: 20px 32px; text-align: center; color: #9CA3AF; font-size: 12px; border-top: 1px solid #E5E7EB;">
      MomRise · Helping moms rise above the chaos
    </div>
  </div>
</body>
</html>`;
}

// Admin-only: create a creator profile directly, without an application.
// For testing/troubleshooting. Links to an existing MomRise user by
// email; if there's no account and a password is supplied, spins up a
// test user. Mirrors approveCreatorApplication's creator-doc shape and
// free-forever comp, but sends no welcome email.
exports.adminCreateCreator = onCall(async (request) => {
  _requireAdmin(request);
  const { email, name, password } = request.data || {};
  if (!email || typeof email !== 'string') {
    throw new HttpsError('invalid-argument', 'email required');
  }
  const cleanEmail = email.trim().toLowerCase();
  const db = getFirestore();
  const auth = getAuth();

  // Resolve the Firebase user — or, with a password, create a test one.
  let uid;
  let createdUser = false;
  try {
    uid = (await auth.getUserByEmail(cleanEmail)).uid;
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      if (!password) {
        throw new HttpsError('failed-precondition',
          `No MomRise account for ${cleanEmail}. Have them sign up first, or pass a password to create a test account.`);
      }
      uid = (await auth.createUser({ email: cleanEmail, password, emailVerified: false })).uid;
      createdUser = true;
    } else {
      throw err;
    }
  }

  // One creator profile per user.
  const existing = await db.collection('creators')
    .where('user_ref', '==', db.doc(`users/${uid}`))
    .limit(1).get();
  if (!existing.empty) {
    throw new HttpsError('already-exists',
      `This user already has a creator profile (code ${existing.docs[0].data().code || '(not set)'}).`);
  }

  const creatorRef = db.collection('creators').doc();
  const batch = db.batch();
  batch.set(creatorRef, {
    name: (name || '').trim() || cleanEmail,
    code: '', // Creator picks their own code on first dashboard visit.
    user_ref: db.doc(`users/${uid}`),
    is_active: true,
    country: 'US',
    bio: '',
    niche: '',
    avatar_url: '',
    follower_count: 0,
    subscriber_count: 0,
    lifetime_payout_cents: 0,
    theme_primary: '#52A097',
    theme_secondary: '#D7F2EB',
    theme_accent: '#EE8B60',
    theme_font: '',
    theme_font_url: '',
    stripe_connect_onboarded: false,
    created_at: FieldValue.serverTimestamp(),
    created_manually: true,
    created_by: request.auth.token.email,
  });
  // Same free-forever comp an approved creator gets.
  batch.set(db.doc(`users/${uid}`), {
    is_comped: true,
    subscription_source: 'creator_comp',
    subscription_status: 'active',
    current_period_end: new Date('2099-12-31T00:00:00Z'),
    comped_at: FieldValue.serverTimestamp(),
    comped_by: request.auth.token.email,
    comped_reason: 'creator_program_manual',
  }, { merge: true });
  await batch.commit();

  return { ok: true, creatorId: creatorRef.id, uid, createdUser };
});

// Called by the creator to update their own profile (name, bio, niche,
// theme_primary). Scope is narrow — the code, stripe fields, and
// counters are off-limits.
exports.updateCreatorProfile = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const { name, bio, niche, theme_primary } = request.data || {};

  const db = getFirestore();
  const uid = request.auth.uid;
  const snap = await db.collection('creators')
    .where('user_ref', '==', db.doc(`users/${uid}`))
    .limit(1).get();
  if (snap.empty) throw new HttpsError('failed-precondition', 'No creator profile for this user');

  const updates = {};
  if (typeof name === 'string') {
    const clean = name.trim().slice(0, 80);
    if (clean) updates.name = clean;
  }
  if (typeof bio === 'string') updates.bio = bio.trim().slice(0, 400);
  if (typeof niche === 'string') updates.niche = niche.trim().slice(0, 120);
  if (typeof theme_primary === 'string') {
    const hex = theme_primary.trim();
    if (!/^#[0-9A-Fa-f]{6}$/.test(hex)) {
      throw new HttpsError('invalid-argument', 'theme_primary must be a 6-digit hex color like #52A097.');
    }
    updates.theme_primary = hex;
  }

  if (Object.keys(updates).length === 0) {
    throw new HttpsError('invalid-argument', 'Nothing to update.');
  }

  await snap.docs[0].ref.update({
    ...updates,
    profile_updated_at: FieldValue.serverTimestamp(),
  });

  return { ok: true, updated: Object.keys(updates) };
});

exports.setCreatorCode = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const { code } = request.data || {};
  if (!code || typeof code !== 'string') {
    throw new HttpsError('invalid-argument', 'Code required');
  }
  const cleaned = code.trim().toUpperCase();
  if (!/^[A-Z0-9]{3,20}$/.test(cleaned)) {
    throw new HttpsError('invalid-argument', 'Code must be 3-20 letters or numbers (A-Z, 0-9).');
  }

  const db = getFirestore();
  const uid = request.auth.uid;

  // Find the caller's creator doc.
  const mySnap = await db.collection('creators')
    .where('user_ref', '==', db.doc(`users/${uid}`))
    .limit(1)
    .get();
  if (mySnap.empty) {
    throw new HttpsError('failed-precondition', 'No creator profile for this user');
  }
  const creatorDoc = mySnap.docs[0];
  const existingCode = creatorDoc.data().code;

  // If a code is already set, allow self-service change once per 365 days.
  if (existingCode && existingCode.trim() !== '') {
    const lastChange = creatorDoc.data().code_set_at?.toDate?.()
      || creatorDoc.data().code_changed_at?.toDate?.();
    const COOLDOWN_DAYS = 365;
    if (lastChange) {
      const daysSince = Math.floor((Date.now() - lastChange.getTime()) / (24 * 60 * 60 * 1000));
      const daysLeft = COOLDOWN_DAYS - daysSince;
      if (daysLeft > 0) {
        throw new HttpsError(
          'failed-precondition',
          `You can change your code once a year. Try again in ${daysLeft} day${daysLeft === 1 ? '' : 's'}, or contact support@momrise.app for help.`,
          { daysLeft, lastChange: lastChange.toISOString() }
        );
      }
    }
  }

  // Uniqueness check.
  const clash = await db.collection('creators').where('code', '==', cleaned).limit(1).get();
  if (!clash.empty && clash.docs[0].id !== creatorDoc.id) {
    throw new HttpsError('already-exists',
      `The code "${cleaned}" is already taken. Try another.`);
  }

  const updates = {
    code: cleaned,
    code_set_at: FieldValue.serverTimestamp(),
  };
  // If this is a CHANGE (not initial set), also stamp code_changed_at so
  // the cooldown clock reflects the most recent change, not the original set.
  if (existingCode && existingCode.trim() !== '') {
    updates.code_changed_at = FieldValue.serverTimestamp();
    updates.previous_code = existingCode;
  }
  await creatorDoc.ref.update(updates);

  return { ok: true, code: cleaned };
});

// ── Follower-side attribution: write the creator code a user came in on ──
//
// Called from the iOS paywall + Settings entry fields ("Got a creator code?").
// Validates the code exists, blocks self-attribution, and writes
// `users/{uid}.active_creator_code = CODE` so the IAP / Stripe webhooks can
// credit the right creator when the user subscribes.
//
// Repeat attribution: allowed (user can change which creator they're
// attributed to before subscribing). Once a subscription exists, the
// active_creator_code at INVOICE time is what gets credited — we don't
// retroactively re-route earnings.
exports.setActiveCreatorCode = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const { code } = request.data || {};
  if (!code || typeof code !== 'string') {
    throw new HttpsError('invalid-argument', 'Code required');
  }
  const cleaned = code.trim().toUpperCase();
  if (!/^[A-Z0-9]{3,20}$/.test(cleaned)) {
    throw new HttpsError(
      'invalid-argument',
      'Code must be 3-20 letters or numbers (A-Z, 0-9).',
    );
  }

  const db = getFirestore();
  const uid = request.auth.uid;

  // Find the creator behind this code. Use the public-facing collection
  // shape (creators/*.code) so we read the same source of truth the
  // dashboard writes to via setCreatorCode.
  const creatorSnap = await db.collection('creators')
    .where('code', '==', cleaned)
    .limit(1)
    .get();
  if (creatorSnap.empty) {
    throw new HttpsError(
      'not-found',
      `We couldn't find a creator with code "${cleaned}". Double-check the spelling — codes are 3-20 letters or numbers.`,
    );
  }
  const creator = creatorSnap.docs[0].data();
  const creatorName = creator.name || 'A MomRise creator';

  // Block self-attribution. A creator can't earn from their own subscription.
  // user_ref is stored as a DocumentReference; compare by id.
  if (creator.user_ref?.id === uid) {
    throw new HttpsError(
      'failed-precondition',
      "You can't use your own creator code — that's why we built the dashboard.",
    );
  }

  await db.collection('users').doc(uid).set({
    active_creator_code: cleaned,
    active_creator_code_set_at: FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    ok: true,
    code: cleaned,
    creator_name: creatorName,
  };
});

// ── Creator data export (GDPR-style "give me my data") ──────
exports.exportCreatorData = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const db = getFirestore();
  const uid = request.auth.uid;
  const userRef = db.doc(`users/${uid}`);

  const creatorSnap = await db.collection('creators')
    .where('user_ref', '==', userRef).limit(1).get();
  if (creatorSnap.empty) throw new HttpsError('failed-precondition', 'No creator profile for this user');

  const creatorDoc = creatorSnap.docs[0];
  const creator = creatorDoc.data();

  // Collect related collections.
  const [earningsSnap, snapshotsSnap, contentSnap, docsSnap] = await Promise.all([
    db.collection('creator_earnings').where('creator_ref', '==', creatorDoc.ref).get(),
    creatorDoc.ref.collection('snapshots').get(),
    db.collection('creator_content').where('creator_ref', '==', creatorDoc.ref).get(),
    db.collection('app_content').where('creator_ref', '==', creatorDoc.ref).get(),
  ]);

  const serialize = (doc) => {
    const data = doc.data();
    // Convert Timestamps to ISO strings; strip DocumentReferences to paths.
    const out = {};
    for (const [k, v] of Object.entries(data)) {
      if (v?.toDate) out[k] = v.toDate().toISOString();
      else if (v?.path) out[k] = v.path;
      else out[k] = v;
    }
    return { _id: doc.id, ...out };
  };

  return {
    exported_at: new Date().toISOString(),
    creator_profile: serialize(creatorDoc),
    earnings: earningsSnap.docs.map(serialize),
    daily_snapshots: snapshotsSnap.docs.map(serialize),
    published_meal_plans_routines: contentSnap.docs.map(serialize),
    published_docs: docsSnap.docs.map(serialize),
  };
});

// ── Creator account deletion request ──────────────────
// Soft-delete: marks the creator as deleted, deactivates them, but the
// admin SDK (you) does the actual permanent purge after a grace period.
// This is the safest pattern — gives time to recover from accidents +
// keeps audit trail intact for accounting.
exports.requestCreatorAccountDeletion = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const db = getFirestore();
  const uid = request.auth.uid;
  const userRef = db.doc(`users/${uid}`);

  const creatorSnap = await db.collection('creators')
    .where('user_ref', '==', userRef).limit(1).get();
  if (creatorSnap.empty) throw new HttpsError('failed-precondition', 'No creator profile for this user');

  await creatorSnap.docs[0].ref.update({
    is_active: false,
    deletion_requested_at: FieldValue.serverTimestamp(),
    deletion_requested_by: 'creator-self',
    deactivated_at: FieldValue.serverTimestamp(),
    deactivated_by: 'creator-self-delete',
  });

  return { ok: true };
});
function _esc(s) { return String(s || '').replace(/[<>&"]/g, c => ({'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;'}[c])); }

// ── Admin creator management ──────────────────────────
// Toggle a creator active/inactive. Inactive creators stop earning,
// stop appearing in follower-facing surfaces, but the doc + history
// stay intact (no destructive deletes).
exports.adminSetCreatorActive = onCall(async (request) => {
  _requireAdmin(request);
  const { creatorId, isActive } = request.data || {};
  if (!creatorId || typeof isActive !== 'boolean') {
    throw new HttpsError('invalid-argument', 'creatorId + isActive (bool) required');
  }
  const db = getFirestore();
  const creatorSnap = await db.collection('creators').doc(creatorId).get();
  if (!creatorSnap.exists) throw new HttpsError('not-found', 'Creator not found');
  await db.collection('creators').doc(creatorId).update({
    is_active: isActive,
    deactivated_at: isActive ? FieldValue.delete() : FieldValue.serverTimestamp(),
    deactivated_by: isActive ? FieldValue.delete() : request.auth.token.email,
  });
  // Toggle the creator's free-forever comp in sync. If they have a real
  // Stripe subscription (stripe_customer_id set) we leave it alone — the
  // webhook owns those fields. Otherwise we flip the comp on/off.
  const userRef = creatorSnap.data().user_ref;
  if (userRef) {
    const userSnap = await userRef.get();
    const u = userSnap.exists ? userSnap.data() : {};
    const hasRealStripeSub = !!u.stripe_customer_id && u.subscription_source !== 'creator_comp';
    if (!hasRealStripeSub) {
      if (isActive) {
        await userRef.set({
          is_comped: true,
          subscription_source: 'creator_comp',
          subscription_status: 'active',
          current_period_end: new Date('2099-12-31T00:00:00Z'),
          comped_at: FieldValue.serverTimestamp(),
        }, { merge: true });
      } else {
        await userRef.set({
          is_comped: false,
          subscription_status: 'canceled',
          subscription_source: FieldValue.delete(),
          comp_revoked_at: FieldValue.serverTimestamp(),
        }, { merge: true });
      }
    }
  }
  return { ok: true };
});

// Admin-only: list the users behind a creator's follower/subscriber counts.
// The creator dashboard deliberately can't do this (users docs are
// owner-only read, which is why the counts are denormalized) — so this is
// an ADMIN tool, gated on ADMIN_EMAILS. It returns emails, so treat the
// output as personal data: it exists so the operator can support a creator,
// not for wholesale export to the creator.
exports.adminListCreatorMembers = onCall(async (request) => {
  _requireAdmin(request);
  const code = String(request.data?.code || '').trim().toUpperCase();
  if (!code) throw new HttpsError('invalid-argument', 'A creator code is required');

  const db = getFirestore();
  const snap = await db.collection('users')
    .where('active_creator_code', '==', code)
    .get();

  const members = snap.docs.map((d) => {
    const u = d.data();
    return {
      uid: d.id,
      email: u.email || '',
      name: u.display_name || '',
      subscribed: _isActiveSub(u),
      subscriptionStatus: u.subscription_status || 'none',
      // ISO string so the client can format without a Timestamp shim.
      followedAt: u.active_creator_code_set_at?.toDate?.()?.toISOString()
        || u.created_time?.toDate?.()?.toISOString()
        || null,
    };
  });

  // Subscribers first, then alphabetical by name/email — most useful order
  // for "who are my subs?".
  members.sort((a, b) => {
    if (a.subscribed !== b.subscribed) return a.subscribed ? -1 : 1;
    return (a.name || a.email).localeCompare(b.name || b.email);
  });

  const subscriberCount = members.filter((m) => m.subscribed).length;
  return { code, followerCount: members.length, subscriberCount, members };
});

// Admin: app-health snapshot. Uses count() aggregation (cheap — server-side,
// doesn't read docs) to gauge activity: new users over time, content created,
// and creator reach. Admin SDK bypasses rules so it can count across all
// users. Rich per-action event counts (button taps etc.) live in GA4 — a
// future tier surfaces those via the Analytics Data API.
exports.getAppHealth = onCall(async (request) => {
  _requireAdmin(request);
  const db = getFirestore();
  const now = Date.now();
  const since = (days) => new Date(now - days * 86400000);
  const d1 = since(1), d7 = since(7), d30 = since(30);

  // count() with a range filter; returns null on error (e.g. missing field)
  // so one bad collection never breaks the whole snapshot.
  const cnt = async (coll, field, from) => {
    try {
      let q = db.collection(coll);
      if (field && from) q = q.where(field, '>=', from);
      const s = await q.count().get();
      return s.data().count;
    } catch (e) {
      console.warn(`getAppHealth count ${coll}/${field || 'total'}: ${e.message}`);
      return null;
    }
  };

  const [
    usersTotal, users1, users7, users30,
    todos1, todos7, todos30,
    routines7, routines30,
    mealPlans, learningPaths, children, recipes, events,
  ] = await Promise.all([
    cnt('users'), cnt('users', 'created_time', d1), cnt('users', 'created_time', d7), cnt('users', 'created_time', d30),
    cnt('todos', 'created_time', d1), cnt('todos', 'created_time', d7), cnt('todos', 'created_time', d30),
    cnt('routines', 'created_at', d7), cnt('routines', 'created_at', d30),
    cnt('meal_plan'), cnt('learning_path'), cnt('childern'), cnt('meal'), cnt('event_and_task'),
  ]);

  // Creator reach — sum denormalized counters.
  let activeCreators = 0, followers = 0, subscribers = 0;
  try {
    const csnap = await db.collection('creators').get();
    csnap.forEach((d) => {
      const c = d.data();
      if (c.is_active !== false) activeCreators++;
      followers += c.follower_count || 0;
      subscribers += c.subscriber_count || 0;
    });
  } catch (e) { console.warn('getAppHealth creators:', e.message); }

  return {
    generated_at: now,
    users: { total: usersTotal, d1: users1, d7: users7, d30: users30 },
    todos: { d1: todos1, d7: todos7, d30: todos30 },
    routines: { d7: routines7, d30: routines30 },
    totals: { mealPlans, learningPaths, children, recipes, events },
    creators: { active: activeCreators, followers, subscribers },
  };
});

// Admin: per-action event counts from Google Analytics (GA4) — the app's
// logged button/action events (meal_plan_created, learning_path_created,
// subscribe, feature_used, screen_view, …). Reads the GA4 Data API using the
// function's own runtime service account (ADC), so no key is stored; that SA
// just needs Viewer access on the GA4 property. Property id comes from the
// Firestore config doc config/app_health.ga4_property_id (set without a
// redeploy). Returns { configured:false } until it's wired up.
const { GoogleAuth } = require('google-auth-library');
// The email the function actually runs as — queried from the metadata server.
// Used to tell the admin exactly which service account to grant GA4 access to.
async function _runtimeSA() {
  try {
    const res = await fetch('http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
      { headers: { 'Metadata-Flavor': 'Google' } });
    if (res.ok) return (await res.text()).trim();
  } catch (_) { /* ignore */ }
  return null;
}
let _gaAuth = null;
async function _ga4Token() {
  if (!_gaAuth) _gaAuth = new GoogleAuth({ scopes: ['https://www.googleapis.com/auth/analytics.readonly'] });
  const client = await _gaAuth.getClient();
  const t = await client.getAccessToken();
  return t.token;
}
async function _ga4Report(propertyId, token, body) {
  const res = await fetch(`https://analyticsdata.googleapis.com/v1beta/properties/${propertyId}:runReport`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`GA4 ${res.status}: ${JSON.stringify(data).slice(0, 300)}`);
  return data;
}

exports.getAppEvents = onCall(async (request) => {
  _requireAdmin(request);
  const db = getFirestore();
  const cfg = (await db.doc('config/app_health').get()).data() || {};
  const propertyId = cfg.ga4_property_id;
  if (!propertyId) return { configured: false };

  try {
    const token = await _ga4Token();

    // Event counts by name for 7d and 30d (two reports → simple merge).
    const eventsReport = (days) => _ga4Report(propertyId, token, {
      dateRanges: [{ startDate: `${days}daysAgo`, endDate: 'today' }],
      dimensions: [{ name: 'eventName' }],
      metrics: [{ name: 'eventCount' }],
      orderBys: [{ metric: { metricName: 'eventCount' }, desc: true }],
      limit: 100,
    });
    const toMap = (rep) => {
      const m = {};
      for (const row of (rep.rows || [])) m[row.dimensionValues[0].value] = Number(row.metricValues[0].value || 0);
      return m;
    };
    const [r7, r30] = await Promise.all([eventsReport(7), eventsReport(30)]);
    const m7 = toMap(r7), m30 = toMap(r30);
    const names = [...new Set([...Object.keys(m7), ...Object.keys(m30)])];
    const events = names
      .map((name) => ({ name, d7: m7[name] || 0, d30: m30[name] || 0 }))
      .sort((a, b) => b.d30 - a.d30);

    // Active users, 7d and 30d.
    const au = await _ga4Report(propertyId, token, {
      dateRanges: [{ startDate: '7daysAgo', endDate: 'today' }, { startDate: '30daysAgo', endDate: 'today' }],
      metrics: [{ name: 'activeUsers' }],
    });
    const auRows = au.rows || [];
    const activeUsers = {
      d7: Number(auRows[0]?.metricValues?.[0]?.value || 0),
      d30: Number(auRows[1]?.metricValues?.[0]?.value || 0),
    };

    return { configured: true, activeUsers, events, generated_at: Date.now() };
  } catch (e) {
    // Include the runtime SA so the admin knows exactly which account to grant.
    return { configured: true, error: e.message, service_account: await _runtimeSA() };
  }
});

// Override a creator's code (e.g., they typed something they regret).
// Same validation rules as setCreatorCode but no caller-owns-doc check.
exports.adminUpdateCreatorCode = onCall(async (request) => {
  _requireAdmin(request);
  const { creatorId, code } = request.data || {};
  if (!creatorId || !code) throw new HttpsError('invalid-argument', 'creatorId + code required');
  const cleaned = String(code).trim().toUpperCase();
  if (!/^[A-Z0-9]{3,20}$/.test(cleaned)) {
    throw new HttpsError('invalid-argument', 'Code must be 3-20 letters or numbers.');
  }
  const db = getFirestore();
  const clash = await db.collection('creators').where('code', '==', cleaned).limit(1).get();
  if (!clash.empty && clash.docs[0].id !== creatorId) {
    throw new HttpsError('already-exists', `Code ${cleaned} is already taken.`);
  }
  await db.collection('creators').doc(creatorId).update({
    code: cleaned,
    code_changed_by_admin_at: FieldValue.serverTimestamp(),
    code_changed_by: request.auth.token.email,
  });
  return { ok: true, code: cleaned };
});

// Override a creator's rev share. Affects every NEW earning event after
// the change — past earning rows store their own rev_share so refunds
// keep mirroring the rate that was actually paid. Field is a number in
// (0, 1] where 0.5 = 50% to the creator. Read by Apple IAP + Stripe
// webhooks via getCreatorRevShare() in functions/{apple_iap,stripe}_*.js.
exports.adminSetCreatorRevShare = onCall(async (request) => {
  _requireAdmin(request);
  const { creatorId, revShare } = request.data || {};
  if (!creatorId) {
    throw new HttpsError('invalid-argument', 'creatorId required');
  }
  const v = Number(revShare);
  if (!Number.isFinite(v) || v <= 0 || v > 1) {
    throw new HttpsError(
      'invalid-argument',
      'revShare must be a number in (0, 1] — e.g. 0.5 for 50%.',
    );
  }
  const db = getFirestore();
  const creatorSnap = await db.collection('creators').doc(creatorId).get();
  if (!creatorSnap.exists) throw new HttpsError('not-found', 'Creator not found');
  await db.collection('creators').doc(creatorId).update({
    rev_share: v,
    rev_share_changed_by_admin_at: FieldValue.serverTimestamp(),
    rev_share_changed_by: request.auth.token.email,
  });
  return { ok: true, rev_share: v };
});

// Re-send the welcome email to a creator (e.g., they lost it).
exports.adminResendWelcomeEmail = onCall(
  { secrets: [sendgridApiKey] },
  async (request) => {
  _requireAdmin(request);
  const { creatorId } = request.data || {};
  if (!creatorId) throw new HttpsError('invalid-argument', 'creatorId required');

  const db = getFirestore();
  const creatorSnap = await db.collection('creators').doc(creatorId).get();
  if (!creatorSnap.exists) throw new HttpsError('not-found', 'Creator not found');
  const creator = creatorSnap.data();

  // Look up the user's email via auth (cleanest source of truth).
  const userPath = creator.user_ref?.path || '';
  const uid = userPath.split('/')[1];
  if (!uid) throw new HttpsError('failed-precondition', 'Creator has no user_ref');
  let email;
  try {
    email = (await getAuth().getUser(uid)).email;
  } catch (err) {
    throw new HttpsError('failed-precondition', `Could not look up email: ${err.message}`);
  }
  if (!email) throw new HttpsError('failed-precondition', 'User has no email on file');

  sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
  await sgMail.send({
    to: email,
    from: sendgridFromEmail.value(),
    subject: `Welcome back to MomRise creator program 🎉`,
    trackingSettings: {
      clickTracking: { enable: false, enableText: false },
      openTracking: { enable: false },
    },
    html: _renderCreatorWelcomeEmail(creator.name),
  });

  return { ok: true, email };
});

exports.rejectCreatorApplication = onCall(
  { secrets: [sendgridApiKey] },
  async (request) => {
  _requireAdmin(request);
  const { applicationId, reason } = request.data || {};
  if (!applicationId) throw new HttpsError('invalid-argument', 'applicationId required');

  const db = getFirestore();
  const appRef = db.collection('creator_applications').doc(applicationId);
  const appSnap = await appRef.get();
  if (!appSnap.exists) throw new HttpsError('not-found', 'Application not found');
  const appData = appSnap.data();

  await appRef.update({
    status: 'rejected',
    rejected_at: FieldValue.serverTimestamp(),
    rejected_by: request.auth.token.email,
    rejection_reason: reason || null,
  });

  // Warm rejection email. Don't fail the whole reject if email fails.
  try {
    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
    await sgMail.send({
      to: appData.email,
      from: sendgridFromEmail.value(),
      subject: 'About your MomRise creator application',
      trackingSettings: {
        clickTracking: { enable: false, enableText: false },
        openTracking: { enable: false },
      },
      html: _renderRejectionEmail(appData.name),
    });
    console.log(`Sent rejection email to ${appData.email}`);
  } catch (err) {
    console.error('Rejection email send failed:', err.message);
    if (err.response?.body) console.error('SendGrid body:', JSON.stringify(err.response.body));
  }

  return { ok: true };
});

function _renderRejectionEmail(name) {
  const first = (name || '').split(' ')[0] || 'there';
  return `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB; line-height: 1.6;">
  <div style="max-width: 560px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 28px 32px; color: white;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85; margin-bottom: 4px;">MomRise Creator Program</div>
      <h1 style="margin: 0; font-size: 22px; font-weight: 700;">Thanks for applying, ${_esc(first)}</h1>
    </div>
    <div style="padding: 28px 32px; color: #374151; font-size: 15px;">
      <p style="margin: 0 0 16px;">We reviewed your application and we're not able to take you on right now. This isn't a judgement on your work — just a timing and fit call on our end as we're keeping the first cohort small and focused.</p>
      <p style="margin: 0 0 16px;">We'd love to revisit down the road if your community grows or the fit changes. No hard feelings.</p>
      <p style="margin: 0 0 16px;">If you're already a MomRise user: we appreciate you. Thank you for caring about the app enough to want to share it.</p>
      <p style="margin: 0; color: #6B7280; font-size: 14px;">Questions or just want to chat? Reply here — we read everything.</p>
    </div>
    <div style="background: #F9FAFB; padding: 18px 32px; text-align: center; color: #9CA3AF; font-size: 12px; border-top: 1px solid #E5E7EB;">
      MomRise · Helping moms rise above the chaos
    </div>
  </div>
</body>
</html>`;
}

// ── Monthly creator stats digest ──────────────────────
// Emails each active creator a recap of the previous calendar month:
// followers gained, subscribers gained, money earned, top doc + meal
// plan. Runs the 11th of each month at 10:00 ET — gives a 24-hour
// buffer after the 10th-of-month payout runner so paid totals are
// settled. Skipped silently when a creator hasn't been onboarded.
exports.monthlyCreatorDigest = onSchedule(
  {
    schedule: '0 10 11 * *',
    timeZone: 'America/New_York',
    secrets: [sendgridApiKey],
  },
  async () => {
    const db = getFirestore();
    const now = new Date();
    // The "previous month" we're reporting on:
    const monthEnd = new Date(now.getFullYear(), now.getMonth(), 1);
    const monthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const monthName = monthStart.toLocaleDateString(undefined, { month: 'long', year: 'numeric' });

    const creatorsSnap = await db.collection('creators').where('is_active', '==', true).get();
    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));

    let sent = 0, skipped = 0;
    for (const creatorDoc of creatorsSnap.docs) {
      const c = creatorDoc.data();

      // Need an email to send to.
      const userPath = c.user_ref?.path || '';
      const uid = userPath.split('/')[1];
      if (!uid) { skipped += 1; continue; }
      let email;
      try { email = (await getAuth().getUser(uid)).email; }
      catch (err) { skipped += 1; continue; }
      if (!email) { skipped += 1; continue; }

      // Pull snapshots in the previous month to compute delta.
      const snapsSnap = await creatorDoc.ref.collection('snapshots')
        .where('date', '>=', _ymd(monthStart))
        .where('date', '<=', _ymd(monthEnd))
        .orderBy('date').get();
      const snaps = snapsSnap.docs.map(d => d.data());
      const startSnap = snaps[0];
      const endSnap = snaps[snaps.length - 1];

      const followerDelta = startSnap && endSnap
        ? (endSnap.follower_count || 0) - (startSnap.follower_count || 0)
        : null;
      const subDelta = startSnap && endSnap
        ? (endSnap.subscriber_count || 0) - (startSnap.subscriber_count || 0)
        : null;

      // Earnings recorded in the previous month.
      const earningsSnap = await db.collection('creator_earnings')
        .where('creator_ref', '==', creatorDoc.ref)
        .get();
      let monthEarned = 0;
      for (const d of earningsSnap.docs) {
        const e = d.data();
        const ts = e.created_at?.toDate?.();
        if (!ts || ts < monthStart || ts >= monthEnd) continue;
        if (e.kind === 'earning' || e.kind === 'clawback') monthEarned += e.creator_cents || 0;
      }

      // Skip creators with literally zero activity — no point emailing them.
      if (monthEarned === 0 && (followerDelta || 0) === 0 && (subDelta || 0) === 0
          && (!c.follower_count || c.follower_count === 0)) {
        skipped += 1; continue;
      }

      try {
        await sgMail.send({
          to: email,
          from: sendgridFromEmail.value(),
          subject: `Your MomRise creator recap — ${monthName}`,
          trackingSettings: { clickTracking: { enable: false }, openTracking: { enable: false } },
          html: _renderMonthlyDigest(c.name, monthName, {
            followerDelta, subDelta, monthEarnedCents: monthEarned,
            totalFollowers: c.follower_count || 0,
            totalSubs: c.subscriber_count || 0,
            code: c.code || '',
          }),
        });
        sent += 1;
      } catch (err) {
        console.error(`Monthly digest send failed for ${email}:`, err.message);
      }
    }
    console.log(`Monthly creator digest: sent ${sent}, skipped ${skipped} (of ${creatorsSnap.size} active).`);
  }
);

function _ymd(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

// Admin-triggered creator brief. Admin composes subject + body (markdown-ish)
// in the dashboard and hits send. Emails go to every active creator's auth
// email. A record gets saved in `creator_briefs` for history.
exports.sendCreatorBrief = onCall(
  { secrets: [sendgridApiKey] },
  async (request) => {
    _requireAdmin(request);
    const { subject, body, cta_text, cta_url, test_only } = request.data || {};
    if (!subject || !body) throw new HttpsError('invalid-argument', 'subject + body required');
    if (subject.length > 120) throw new HttpsError('invalid-argument', 'subject too long');
    if (body.length > 20000) throw new HttpsError('invalid-argument', 'body too long');

    const db = getFirestore();
    const creatorsSnap = await db.collection('creators').where('is_active', '==', true).get();

    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
    const from = sendgridFromEmail.value();

    // If test_only, just send to the admin.
    const recipients = [];
    if (test_only) {
      recipients.push({ email: request.auth.token.email, name: 'Admin (test)', code: 'TEST' });
    } else {
      for (const doc of creatorsSnap.docs) {
        const c = doc.data();
        const uid = c.user_ref?.path?.split('/')[1];
        if (!uid) continue;
        let email;
        try { email = (await getAuth().getUser(uid)).email; }
        catch (_) { continue; }
        if (!email) continue;
        recipients.push({ email, name: c.name || '', code: c.code || '' });
      }
    }

    let sent = 0, failed = 0;
    for (const r of recipients) {
      try {
        await sgMail.send({
          to: r.email,
          from,
          subject,
          trackingSettings: { clickTracking: { enable: false }, openTracking: { enable: false } },
          html: _renderCreatorBrief({ subject, body, cta_text, cta_url, name: r.name, code: r.code }),
        });
        sent += 1;
      } catch (err) {
        console.error(`Brief send failed for ${r.email}:`, err.message);
        failed += 1;
      }
    }

    if (!test_only) {
      await db.collection('creator_briefs').add({
        subject,
        body,
        cta_text: cta_text || null,
        cta_url: cta_url || null,
        sent_count: sent,
        failed_count: failed,
        sent_at: FieldValue.serverTimestamp(),
        sent_by: request.auth.token.email,
      });
    }
    return { ok: true, sent, failed, test_only: !!test_only };
  }
);

function _renderCreatorBrief({ subject, body, cta_text, cta_url, name, code }) {
  const first = (name || '').split(' ')[0] || 'there';
  // Tiny markdown-ish renderer: ##/###/paragraphs/lists/**bold**/links.
  const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
  const renderInline = (s) => esc(s)
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" style="color: #2A6F67; text-decoration: underline;">$1</a>');
  const lines = body.split(/\r?\n/);
  const html = [];
  let inList = false;
  for (const raw of lines) {
    const line = raw.replace(/\s+$/, '');
    if (/^###\s+/.test(line)) {
      if (inList) { html.push('</ul>'); inList = false; }
      html.push(`<h3 style="font-size: 16px; margin: 22px 0 8px; color: #1F2937;">${renderInline(line.replace(/^###\s+/, ''))}</h3>`);
    } else if (/^##\s+/.test(line)) {
      if (inList) { html.push('</ul>'); inList = false; }
      html.push(`<h2 style="font-size: 20px; margin: 28px 0 10px; color: #2A6F67;">${renderInline(line.replace(/^##\s+/, ''))}</h2>`);
    } else if (/^[-*]\s+/.test(line)) {
      if (!inList) { html.push('<ul style="padding-left: 20px; margin: 0 0 12px; line-height: 1.65;">'); inList = true; }
      html.push(`<li>${renderInline(line.replace(/^[-*]\s+/, ''))}</li>`);
    } else if (!line) {
      if (inList) { html.push('</ul>'); inList = false; }
    } else {
      if (inList) { html.push('</ul>'); inList = false; }
      html.push(`<p style="margin: 0 0 14px; line-height: 1.65;">${renderInline(line)}</p>`);
    }
  }
  if (inList) html.push('</ul>');
  const ctaBlock = cta_text && cta_url
    ? `<div style="margin: 28px 0 8px;"><a href="${esc(cta_url)}" style="display: inline-block; background: #52A097; color: white; padding: 12px 22px; border-radius: 10px; text-decoration: none; font-weight: 600;">${esc(cta_text)}</a></div>`
    : '';
  return `<!DOCTYPE html><html><body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB;">
<div style="max-width: 600px; margin: 0 auto; padding: 32px 20px;">
  <div style="background: white; border-radius: 16px; padding: 32px 30px; box-shadow: 0 10px 30px -15px rgba(0,0,0,0.15);">
    <div style="font-size: 12px; letter-spacing: 0.08em; text-transform: uppercase; color: #52A097; font-weight: 600; margin-bottom: 6px;">MomRise · Creator brief</div>
    <p style="margin: 0 0 22px; color: #6B7280; font-size: 14px;">Hey ${esc(first)} —</p>
    ${html.join('\n')}
    ${ctaBlock}
    <div style="margin-top: 32px; padding-top: 20px; border-top: 1px solid #E5E7EB; font-size: 13px; color: #6B7280; line-height: 1.55;">
      Your code: <code style="background: #F3F4F6; padding: 2px 8px; border-radius: 4px; color: #2A6F67; font-weight: 600;">${esc(code || '—')}</code> · <a href="https://momrise.app/creator/" style="color: #6B7280;">Creator dashboard</a>
      <br>Questions? Reply to this email or hit us at <a href="mailto:creators@momrise.app" style="color: #6B7280;">creators@momrise.app</a>.
    </div>
  </div>
</div>
</body></html>`;
}

function _renderMonthlyDigest(name, monthName, m) {
  const first = (name || '').split(' ')[0] || 'there';
  const fmtDelta = (n) => n === null ? '—' : (n > 0 ? `+${n}` : `${n}`);
  const fmtMoney = (cents) => `$${(cents / 100).toFixed(2)}`;
  const headline = m.monthEarnedCents > 0
    ? `You earned ${fmtMoney(m.monthEarnedCents)} in ${monthName} 🎉`
    : (m.followerDelta || 0) > 0
      ? `You gained ${m.followerDelta} new follower${m.followerDelta === 1 ? '' : 's'} in ${monthName}`
      : `Your ${monthName} recap`;
  return `
<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; margin:0; padding:0; background:#F9FAFB; line-height:1.55;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 32px 32px; color: white; text-align: center;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85; margin-bottom: 6px;">${_esc(monthName)} recap</div>
      <h1 style="margin: 0; font-size: 22px;">${_esc(headline)}</h1>
    </div>
    <div style="padding: 28px 32px; color: #374151; font-size: 15px;">
      <p style="margin: 0 0 18px;">Hey ${_esc(first)} — here's how your creator code <strong style="font-family:'SF Mono',Consolas,monospace; color:#2A6F67;">${_esc(m.code)}</strong> did last month.</p>

      <table style="width:100%; border-collapse: collapse;">
        <tr><td style="padding: 10px 0; color: #6B7280; font-size: 13px;">New followers</td><td style="padding: 10px 0; text-align: right; font-weight: 600; font-size: 18px;">${fmtDelta(m.followerDelta)}</td></tr>
        <tr><td style="padding: 10px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">New subscribers</td><td style="padding: 10px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">${fmtDelta(m.subDelta)}</td></tr>
        <tr><td style="padding: 10px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">You earned</td><td style="padding: 10px 0; text-align: right; font-weight: 700; font-size: 22px; border-top: 1px solid #F3F4F6; color: #2A6F67;">${fmtMoney(m.monthEarnedCents)}</td></tr>
        <tr><td style="padding: 10px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Lifetime followers</td><td style="padding: 10px 0; text-align: right; font-weight: 600; font-size: 16px; border-top: 1px solid #F3F4F6; color: #6B7280;">${m.totalFollowers}</td></tr>
        <tr><td style="padding: 10px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Active subscribers</td><td style="padding: 10px 0; text-align: right; font-weight: 600; font-size: 16px; border-top: 1px solid #F3F4F6; color: #6B7280;">${m.totalSubs}</td></tr>
      </table>

      <div style="text-align: center; margin: 28px 0 8px;">
        <a href="https://momrise.app/creator/" style="display:inline-block;background:#52A097;color:white !important;text-decoration:none;padding:12px 28px;border-radius:10px;font-weight:600;font-size:14px;">See full dashboard →</a>
      </div>

      <p style="margin: 24px 0 0; font-size: 13px; color: #6B7280;">Got a moment to keep growing? Pop into your <a href="https://momrise.app/creator/" style="color:#52A097;">share kit</a> for a fresh post template.</p>
    </div>
    <div style="background:#F9FAFB; padding: 16px 32px; text-align:center; color:#9CA3AF; font-size:12px; border-top:1px solid #E5E7EB;">MomRise · You're getting this because you're an active creator. Reply to opt out.</div>
  </div>
</body></html>`;
}

// ── Weekly admin digest email ─────────────────────────
// Mondays at 9:00 America/New_York. Sends collinjmaddox@gmail.com a
// summary so issues surface before creators complain.
exports.weeklyAdminDigest = onSchedule(
  {
    schedule: '0 9 * * 1',
    timeZone: 'America/New_York',
    secrets: [sendgridApiKey],
  },
  async () => {
    const db = getFirestore();
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [pendingApps, allCreators, paidEarnings] = await Promise.all([
      db.collection('creator_applications').where('status', '==', 'new').get(),
      db.collection('creators').get(),
      db.collection('creator_earnings').where('payout_status', '==', 'paid').get(),
    ]);

    const newCreatorsThisWeek = allCreators.docs.filter(d => {
      const t = d.data().created_at?.toDate?.();
      return t && t >= weekAgo;
    });
    const activeCreators = allCreators.docs.filter(d => d.data().is_active !== false);

    const totalFollowers = allCreators.docs.reduce((s, d) => s + (d.data().follower_count || 0), 0);
    const totalSubs = allCreators.docs.reduce((s, d) => s + (d.data().subscriber_count || 0), 0);

    let paidThisMonth = 0;
    for (const d of paidEarnings.docs) {
      const e = d.data();
      const paidAt = e.paid_at?.toDate?.();
      if (paidAt && paidAt >= monthStart) paidThisMonth += e.creator_cents || 0;
    }

    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
    await sgMail.send({
      to: 'collinjmaddox@gmail.com',
      from: sendgridFromEmail.value(),
      subject: `MomRise weekly digest · ${now.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}`,
      trackingSettings: { clickTracking: { enable: false }, openTracking: { enable: false } },
      html: `
<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; margin:0; padding:0; background:#F9FAFB; line-height:1.55;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 28px 32px; color: white;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85;">MomRise · Weekly Digest</div>
      <h1 style="margin: 4px 0 0; font-size: 22px;">Week of ${now.toLocaleDateString(undefined, { month: 'long', day: 'numeric' })}</h1>
    </div>
    <div style="padding: 24px 32px; color: #374151; font-size: 15px;">
      <table style="width:100%; border-collapse: collapse; margin-bottom: 18px;">
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px;">Pending applications</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px;">${pendingApps.size}</td></tr>
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">New creators this week</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">${newCreatorsThisWeek.length}</td></tr>
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Active creators</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">${activeCreators.length}</td></tr>
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Total followers</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">${totalFollowers}</td></tr>
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Total subscribers</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">${totalSubs}</td></tr>
        <tr><td style="padding: 8px 0; color: #6B7280; font-size: 13px; border-top: 1px solid #F3F4F6;">Paid to creators this month</td><td style="padding: 8px 0; text-align: right; font-weight: 600; font-size: 18px; border-top: 1px solid #F3F4F6;">$${(paidThisMonth / 100).toFixed(2)}</td></tr>
      </table>
      ${pendingApps.size > 0 ? `<div style="background: #FEF3C7; border-radius: 8px; padding: 12px 14px; font-size: 14px; color: #92400E;">⏰ <strong>${pendingApps.size} application${pendingApps.size === 1 ? '' : 's'} waiting on you</strong> — they're sitting in the inbox.</div>` : ''}
      <div style="text-align: center; margin: 24px 0 8px;">
        <a href="https://momrise.app/admin/" style="display:inline-block;background:#52A097;color:white !important;text-decoration:none;padding:12px 28px;border-radius:10px;font-weight:600;font-size:14px;">Open admin dashboard →</a>
      </div>
    </div>
    <div style="background:#F9FAFB; padding: 16px 32px; text-align:center; color:#9CA3AF; font-size:12px; border-top:1px solid #E5E7EB;">Weekly · Mondays at 9 AM ET · MomRise admin</div>
  </div>
</body></html>`,
    });
    console.log(`Weekly digest sent. ${pendingApps.size} pending, ${newCreatorsThisWeek.length} new this week.`);
  }
);

// ── Daily creator metric snapshots ───────────────────
// Stamps follower_count / subscriber_count / lifetime_payout_cents for
// every creator once a day. The dashboard reads these back as a line
// chart "followers & subscribers over time". Deduped on the date key
// so accidental re-runs don't double-stamp.
exports.snapshotCreatorMetrics = onSchedule(
  {
    schedule: '5 1 * * *',
    timeZone: 'America/New_York',
  },
  async () => {
    const db = getFirestore();
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    const dateKey = `${y}-${m}-${d}`;

    const creatorsSnap = await db.collection('creators').get();
    let written = 0;
    for (const creatorDoc of creatorsSnap.docs) {
      const c = creatorDoc.data();
      await creatorDoc.ref.collection('snapshots').doc(dateKey).set({
        date: dateKey,
        taken_at: FieldValue.serverTimestamp(),
        follower_count: c.follower_count || 0,
        subscriber_count: c.subscriber_count || 0,
        lifetime_payout_cents: c.lifetime_payout_cents || 0,
      }, { merge: true });
      written += 1;
    }
    console.log(`Snapshotted ${written} creators for ${dateKey}`);
  }
);

exports.maintainCreatorFollowerCount = onDocumentWritten(
  'users/{uid}',
  async (event) => {
    const before = event.data.before.exists ? event.data.before.data() : null;
    const after = event.data.after.exists ? event.data.after.data() : null;

    const beforeCode = before?.active_creator_code || null;
    const afterCode = after?.active_creator_code || null;
    const beforeSub = _isActiveSub(before) && beforeCode;
    const afterSub = _isActiveSub(after) && afterCode;

    const ops = [];

    // Follower: any user with an active_creator_code set.
    if (beforeCode !== afterCode) {
      if (beforeCode) ops.push(_adjustCreatorCounter(beforeCode, 'follower_count', -1));
      if (afterCode) ops.push(_adjustCreatorCounter(afterCode, 'follower_count', 1));
    }

    // Subscriber: active sub with code set.
    if (beforeSub !== afterSub || beforeCode !== afterCode) {
      if (beforeSub) ops.push(_adjustCreatorCounter(beforeCode, 'subscriber_count', -1));
      if (afterSub) ops.push(_adjustCreatorCounter(afterCode, 'subscriber_count', 1));
    }

    await Promise.all(ops);
  }
);
