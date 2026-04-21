// MomRise Cloud Functions - v2 (Node 22)
const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
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
      sgMail.setApiKey(sendgridApiKey.value());

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
  "cookTime": 30
}

Important:
- Extract ALL ingredients as separate array items
- Extract ALL instruction steps as separate array items
- If servings shows "4,serves 4", just return "4"
- prepTime and cookTime must be integers in MINUTES (not strings, not ISO durations). Use 0 if not found.
- Do not include any text outside the JSON
- Return empty strings/arrays if data not found

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
  "sourceUrl": "${recipe.sourceUrl}"
}

CRITICAL:
- Split combined instruction steps into separate array items
- Each instruction should be ONE action/step only
- Do not combine multiple steps into one string
- Clean up servings format`;

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
  "cookTime": 30
}

prepTime and cookTime must be integers in MINUTES (0 if not visible).
If the image is just a food photo with no recipe text, return {"error": "no recipe found"}.
Return ONLY valid JSON.`
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
  "cookTime": 30
}

PASTED TEXT:
${text}

CRITICAL:
- Extract the recipe name from the text
- Parse all ingredients into separate array items
- Parse all instructions/steps into separate array items
- Each instruction should be ONE step only
- prepTime and cookTime must be integers in MINUTES. Use 0 if not mentioned.
- Return only valid JSON, no markdown formatting`;

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

// ── Stripe Subscription Functions ───────────────────
const stripeFunctions = require('./stripe_functions');
exports.createSubscription = stripeFunctions.createSubscription;
exports.cancelSubscription = stripeFunctions.cancelSubscription;
exports.restorePurchases = stripeFunctions.restorePurchases;
exports.stripeWebhook = stripeFunctions.stripeWebhook;
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
            { type: 'image', source: { type: 'base64', media_type: 'image/jpeg', data: imageBase64 } },
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
  await snap.docs[0].ref.update({ [field]: FieldValue.increment(delta) });
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
      sgMail.setApiKey(sendgridApiKey.value());
      const appId = snap.id;
      const esc = (s) => String(s || '').replace(/[<>&]/g, c => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]));

      await sgMail.send({
        to: 'collinjmaddox@gmail.com',
        from: sendgridFromEmail.value(),
        subject: `New creator application: ${d.name || '(no name)'}`,
        html: `
          <div style="font-family: Inter, system-ui, sans-serif; max-width: 600px; margin: 0 auto; color: #1F2937; line-height: 1.6;">
            <h2 style="color: #2A6F67; border-bottom: 2px solid #52A097; padding-bottom: 8px;">New creator application</h2>
            <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
              <tr><td style="padding: 8px 12px; background: #F9FAFB; width: 140px;"><b>Name</b></td><td style="padding: 8px 12px;">${esc(d.name)}</td></tr>
              <tr><td style="padding: 8px 12px; background: #F9FAFB;"><b>Email</b></td><td style="padding: 8px 12px;"><a href="mailto:${esc(d.email)}">${esc(d.email)}</a></td></tr>
              <tr><td style="padding: 8px 12px; background: #F9FAFB;"><b>Handle</b></td><td style="padding: 8px 12px;">${esc(d.primary_handle)}</td></tr>
              ${d.other_handles ? `<tr><td style="padding: 8px 12px; background: #F9FAFB;"><b>Other</b></td><td style="padding: 8px 12px;">${esc(d.other_handles)}</td></tr>` : ''}
              <tr><td style="padding: 8px 12px; background: #F9FAFB;"><b>Audience</b></td><td style="padding: 8px 12px;">${esc(d.audience_size)}</td></tr>
              <tr><td style="padding: 8px 12px; background: #F9FAFB;"><b>Website</b></td><td style="padding: 8px 12px;">${d.website ? `<a href="${esc(d.website)}">${esc(d.website)}</a>` : '<i>(none)</i>'}</td></tr>
              <tr><td style="padding: 8px 12px; background: #F9FAFB; vertical-align: top;"><b>Community</b></td><td style="padding: 8px 12px;">${esc(d.audience_description)}</td></tr>
              <tr><td style="padding: 8px 12px; background: #F9FAFB; vertical-align: top;"><b>Pitch</b></td><td style="padding: 8px 12px;">${esc(d.pitch)}</td></tr>
            </table>
            <p style="background: #EFF6FF; padding: 12px 16px; border-radius: 8px; font-size: 14px;">
              <b>To approve:</b> <code style="background: white; padding: 2px 6px; border-radius: 4px;">node admin/approve-creator.js ${appId}</code>
            </p>
            <p style="color: #6B7280; font-size: 13px;">Application ID: ${appId}</p>
          </div>`,
      });
      console.log(`Sent creator-application notification for ${appId}`);
    } catch (err) {
      console.error('Failed to send creator-application notification:', err.message);
    }
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
