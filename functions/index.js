// MomRise Cloud Functions - v2 (Node 22)
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const sgMail = require('@sendgrid/mail');
const https = require('https');
const http = require('http');

initializeApp();

// ── Stripe Subscription Functions ────────────────────
const {
  createSubscription,
  cancelSubscription,
  restorePurchases,
  stripeWebhook,
} = require('./stripe_functions');

exports.createSubscription = createSubscription;
exports.cancelSubscription = cancelSubscription;
exports.restorePurchases = restorePurchases;
exports.stripeWebhook = stripeWebhook;

// ── Configuration ─────────────────────────────────────
// Non-secret values from .env
const sendgridFromEmail = defineString('SENDGRID_FROM_EMAIL');

// Secret values from Cloud Secret Manager
const sendgridApiKey = defineSecret('SENDGRID_API_KEY');

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
exports.extractRecipe = onRequest(async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight OPTIONS request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  // Extract URL from request body
  const { data } = request.body;
  const { url } = data || {};

  if (!url) {
    response.status(400).json({
      result: { error: 'URL is required' }
    });
    return;
  }

  console.log(`Extracting recipe from: ${url}`);

  try {
    // Fetch the URL with redirect following
    const html = await fetchUrl(url);
    console.log(`Fetched HTML (length: ${html.length})`);

    // Check if this is a Pinterest pin (not a recipe site)
    const finalUrl = url.includes('pin.it') || url.includes('pinterest.com')
      ? 'pinterest.com'
      : url;

    if (finalUrl.includes('pinterest.com') || html.includes('SocialMediaPosting')) {
      // Try to extract the source URL from Pinterest pin
      const sourceUrl = extractPinterestSourceUrl(html);
      if (sourceUrl) {
        console.log(`Found Pinterest source URL: ${sourceUrl}`);
        // Recursively fetch the actual recipe from source
        const sourceHtml = await fetchUrl(sourceUrl);
        const recipe = extractRecipeFromHtml(sourceHtml, sourceUrl);
        if (recipe) {
          console.log(`Successfully extracted recipe: ${recipe.name}`);
          response.status(200).json({ result: recipe });
          return;
        }
      }

      // No source URL found or recipe extraction failed
      response.status(404).json({
        result: {
          error: 'This Pinterest pin doesn\'t link to a recipe page. Please open the pin in Pinterest and share the original recipe website instead.'
        }
      });
      return;
    }

    // Extract recipe from HTML
    const recipe = extractRecipeFromHtml(html, url);

    if (!recipe) {
      response.status(404).json({
        result: { error: 'No recipe found at this URL' }
      });
      return;
    }

    console.log(`Successfully extracted recipe: ${recipe.name}`);
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
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    }, (response) => {
      // Handle redirects
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        let redirectUrl = response.headers.location;
        console.log(`Redirect to: ${redirectUrl}`);
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

// Helper: Extract recipe from HTML using JSON-LD
function extractRecipeFromHtml(html, sourceUrl) {
  // Try to find JSON-LD structured data
  const jsonLdMatches = html.match(/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi);

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
      instructions = recipe.recipeInstructions.map(step => {
        if (typeof step === 'string') return step;
        if (step.text) return step.text;
        if (step.itemListElement) {
          return step.itemListElement.map(s => s.text || s).join(' ');
        }
        return String(step);
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

  return {
    name: recipe.name || 'Untitled Recipe',
    description: recipe.description || '',
    imageUrl: imageUrl,
    ingredients: ingredients.filter(i => i && i.trim()),
    instructions: instructions.filter(i => i && i.trim()),
    servings: recipe.recipeYield ? String(recipe.recipeYield) : '',
    sourceUrl: sourceUrl
  };
}
