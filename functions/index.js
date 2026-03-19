// MomRise Cloud Functions - v2 (Node 22)
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineString, defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const sgMail = require('@sendgrid/mail');

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
