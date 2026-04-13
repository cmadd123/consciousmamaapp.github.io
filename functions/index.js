// MomRise Cloud Functions - v2 (Node 22)
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onCall, onRequest } = require('firebase-functions/v2/https');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
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
exports.extractRecipe = onRequest({ secrets: [openaiApiKey, scrapingBeeApiKey] }, async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight OPTIONS request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
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
      // Try to extract the source URL from Pinterest pin
      const sourceUrl = extractPinterestSourceUrl(html);
      if (sourceUrl) {
        console.log(`Found Pinterest source URL: ${sourceUrl}`);
        // Fetch the actual recipe from source (try direct, then ScrapingBee)
        let sourceHtml;
        try {
          sourceHtml = await fetchUrl(sourceUrl);
          if (sourceHtml.length < 500 || sourceHtml.includes('Just a moment')) {
            throw new Error('Blocked');
          }
        } catch (e) {
          console.log(`Direct fetch of source failed, trying ScrapingBee...`);
          sourceHtml = await fetchWithScrapingBee(sourceUrl, scrapingBeeApiKey.value());
        }
        const recipe = extractRecipeFromHtml(sourceHtml, sourceUrl);
        if (recipe) {
          console.log(`Successfully extracted recipe: ${recipe.name}`);
          response.status(200).json({ result: recipe });
          return;
        }
      }

      // No source URL found or recipe extraction from source failed
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
            response.status(200).json({ result: recipe });
            return;
          }
        } catch (visionError) {
          console.error(`Vision extraction failed: ${visionError.message}`);
        }
      }

      // All methods failed
      response.status(404).json({
        result: {
          error: 'Could not extract a recipe from this pin. The image may not contain recipe text.\n\nTry:\n1. Open the pin in Pinterest and tap "Visit"\n2. Paste that website URL instead\n3. Or manually enter the recipe'
        }
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

// Helper: Fetch URL using ScrapingBee (handles Cloudflare, JS rendering, bot protection)
function fetchWithScrapingBee(url, apiKey) {
  return new Promise((resolve, reject) => {
    if (!apiKey) {
      reject(new Error('ScrapingBee API key not configured'));
      return;
    }

    const params = new URLSearchParams({
      api_key: apiKey,
      url: url,
      render_js: 'false',        // Don't need JS rendering for most recipe blogs
      premium_proxy: 'true',     // Uses residential proxies to bypass Cloudflare
      country_code: 'us',
    });

    const sbUrl = `https://app.scrapingbee.com/api/v1/?${params.toString()}`;

    https.get(sbUrl, {
      timeout: 45000,
    }, (response) => {
      if (response.statusCode !== 200) {
        // Read error body for details
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

  return {
    name: recipe.name || 'Untitled Recipe',
    description: recipe.description || '',
    imageUrl: imageUrl,
    ingredients: ingredients.filter(i => i && i.trim()),
    instructions: instructions.filter(i => i && i.trim()),
    servings: servings,
    sourceUrl: sourceUrl
  };
}

// Helper: Extract recipe using OpenAI when structured data fails
async function extractRecipeWithAI(html, sourceUrl, apiKey) {
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
  "servings": "number of servings"
}

Important:
- Extract ALL ingredients as separate array items
- Extract ALL instruction steps as separate array items
- If servings shows "4,serves 4", just return "4"
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
  "servings": "number if visible"
}

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

async function extractRecipeFromTextWithAI(text, apiKey) {
  console.log(`Extracting recipe from text with AI (length: ${text.length})`);

  const prompt = `Extract the recipe from this pasted text. Return ONLY valid JSON with this exact structure:
{
  "name": "Recipe Name",
  "description": "Brief description if available",
  "imageUrl": "",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", ...],
  "servings": "number of servings if mentioned"
}

PASTED TEXT:
${text}

CRITICAL:
- Extract the recipe name from the text
- Parse all ingredients into separate array items
- Parse all instructions/steps into separate array items
- Each instruction should be ONE step only
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
