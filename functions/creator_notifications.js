// Fire an email to the creator when a new earning lands in their
// ledger. Works for both Apple-IAP and Stripe paths because both write
// to creator_earnings with the same row shape.
//
// Triggered on every creator_earnings doc created. Skips:
//   - Sandbox earnings (internal IAP test runs)
//   - Clawbacks (don't congratulate creators for refunds)
//   - Rows missing creator_ref / creator email
//
// Email send failures are logged but never thrown — the ledger write
// already succeeded, and the creator can always see the earning land
// on the dashboard regardless of email delivery.

const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { defineString, defineSecret } = require('firebase-functions/params');
const { getFirestore } = require('firebase-admin/firestore');
const sgMail = require('@sendgrid/mail');

const sendgridApiKey = defineSecret('SENDGRID_API_KEY');
const sendgridFromEmail = defineString('SENDGRID_FROM_EMAIL');

exports.notifyOnCreatorEarning = onDocumentCreated(
  {
    document: 'creator_earnings/{id}',
    secrets: [sendgridApiKey],
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const e = snap.data();

    if (e.kind !== 'earning') return;
    if (e.environment === 'Sandbox') return;
    if (!e.creator_ref) return;
    if (!(e.creator_cents > 0)) return;

    const creatorSnap = await e.creator_ref.get();
    if (!creatorSnap.exists) return;
    const creator = creatorSnap.data();
    const email = creator.email;
    if (!email) {
      console.warn(
        `[earning-notify] creator ${creatorSnap.id} has no email — skipping`,
      );
      return;
    }

    const firstName = (creator.name || 'there').split(' ')[0];
    const amountStr = `$${(e.creator_cents / 100).toFixed(2)}`;
    const sourceLabel =
      e.source === 'apple_iap' ? 'iOS' : e.source === 'stripe' ? 'web' : '';

    try {
      sgMail.setApiKey(
        sendgridApiKey.value().replace(/[\s\r\n]+/g, ''),
      );
      await sgMail.send({
        to: email,
        from: sendgridFromEmail.value(),
        subject: `You just earned ${amountStr} on MomRise 💸`,
        trackingSettings: {
          clickTracking: { enable: false, enableText: false },
          openTracking: { enable: false },
        },
        html: _renderEarningEmail({
          firstName,
          amountStr,
          sourceLabel,
          creatorCode: e.creator_code || '',
          eligibleDate: _formatEligibleDate(e.created_at),
        }),
      });
      console.log(
        `[earning-notify] sent ${amountStr} earning email to ${email}`,
      );
    } catch (err) {
      console.error(
        `[earning-notify] send failed for ${email}: ${err.message}`,
      );
      if (err.response?.body) {
        console.error('SendGrid body:', JSON.stringify(err.response.body));
      }
    }
  },
);

// Notify the creator when a payout transfer actually fires. Triggered
// on creators/{id} update where last_payout_at changes — runCreatorPayouts
// stamps that field after a successful Stripe transfer.
//
// Skips:
//   - creator with no email
//   - last_payout_at unchanged (any other update to the doc)
//   - zero-amount payouts (shouldn't happen but defensive)
exports.notifyOnCreatorPayout = onDocumentUpdated(
  {
    document: 'creators/{id}',
    secrets: [sendgridApiKey],
  },
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};

    const beforeAt = before.last_payout_at?.toMillis?.() || 0;
    const afterAt = after.last_payout_at?.toMillis?.() || 0;
    if (afterAt === 0 || afterAt === beforeAt) return;

    const amountCents = after.last_payout_cents || 0;
    if (amountCents <= 0) return;

    const email = after.email;
    if (!email) {
      console.warn(
        `[payout-notify] creator ${event.params.id} has no email — skipping`,
      );
      return;
    }

    const firstName = (after.name || 'there').split(' ')[0];
    const amountStr = `$${(amountCents / 100).toFixed(2)}`;
    const lifetimeStr = `$${((after.lifetime_payout_cents || 0) / 100).toFixed(2)}`;

    try {
      sgMail.setApiKey(
        sendgridApiKey.value().replace(/[\s\r\n]+/g, ''),
      );
      await sgMail.send({
        to: email,
        from: sendgridFromEmail.value(),
        subject: `${amountStr} just landed in your bank from MomRise`,
        trackingSettings: {
          clickTracking: { enable: false, enableText: false },
          openTracking: { enable: false },
        },
        html: _renderPayoutEmail({ firstName, amountStr, lifetimeStr }),
      });
      console.log(
        `[payout-notify] sent ${amountStr} payout email to ${email}`,
      );
    } catch (err) {
      console.error(
        `[payout-notify] send failed for ${email}: ${err.message}`,
      );
      if (err.response?.body) {
        console.error('SendGrid body:', JSON.stringify(err.response.body));
      }
    }
  },
);

function _renderPayoutEmail({ firstName, amountStr, lifetimeStr }) {
  const esc = (s) =>
    String(s || '').replace(/[<>&]/g, (c) => ({
      '<': '&lt;',
      '>': '&gt;',
      '&': '&amp;',
    }[c]));
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB; line-height: 1.6;">
  <div style="max-width: 560px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #2A6F67 100%); padding: 32px 32px 28px; color: white; text-align: center;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.85; margin-bottom: 6px;">Payout sent</div>
      <h1 style="margin: 0; font-size: 26px; font-weight: 700;">${esc(amountStr)} just landed</h1>
      <p style="margin: 8px 0 0; font-size: 14px; opacity: 0.92;">Your monthly MomRise creator payout is on its way to your bank.</p>
    </div>
    <div style="padding: 28px 32px;">
      <p style="margin: 0 0 14px; font-size: 16px; color: #1F2937;">Hey ${esc(firstName)},</p>
      <p style="margin: 0 0 14px; font-size: 16px; color: #1F2937;">We just transferred <strong>${esc(amountStr)}</strong> to your Stripe Connect account. Stripe normally moves it to your bank within 1-2 business days.</p>
      <p style="margin: 0 0 22px; font-size: 14px; color: #6B7280;">Lifetime payouts to date: <strong style="color: #2A6F67;">${esc(lifetimeStr)}</strong>. Thank you for sharing MomRise — we built this program because moms like the ones you reach are the whole reason MomRise exists.</p>
      <div style="text-align: center;">
        <a href="https://momrise.app/creator/" style="display: inline-block; background: #52A097; color: white; padding: 12px 24px; border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 15px;">View payout details →</a>
      </div>
    </div>
    <div style="padding: 12px 32px 24px; text-align: center; font-size: 12px; color: #9CA3AF;">
      Track every payout in your dashboard. Questions? Reply to this email.
    </div>
  </div>
</body>
</html>`;
}

// Format the payout-eligible date for an earning. Earnings need to be 30
// days old before they're swept into a payout cycle (the holdback in
// runCreatorPayouts). Returns a human-readable date string the creator
// email can show ("June 30, 2026").
function _formatEligibleDate(createdAt) {
  try {
    const created = createdAt?.toDate?.() || new Date();
    // 45-day holdback (matches runCreatorPayouts), then the next
    // monthly payout run on the 10th picks it up.
    const eligible = new Date(created.getTime() + 45 * 24 * 60 * 60 * 1000);
    const payday = new Date(eligible.getFullYear(), eligible.getMonth(), 10);
    if (payday < eligible) payday.setMonth(payday.getMonth() + 1);
    return payday.toLocaleDateString('en-US', {
      year: 'numeric', month: 'long', day: 'numeric',
    });
  } catch (_) {
    return 'about six to nine weeks from now';
  }
}

function _renderEarningEmail({ firstName, amountStr, sourceLabel, creatorCode, eligibleDate }) {
  const esc = (s) =>
    String(s || '').replace(/[<>&]/g, (c) => ({
      '<': '&lt;',
      '>': '&gt;',
      '&': '&amp;',
    }[c]));
  const sourceLine = sourceLabel
    ? `<span style="color: #6B7280; font-size: 14px;">From a ${esc(sourceLabel)} subscription</span>`
    : '';
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 0; background: #F9FAFB; line-height: 1.6;">
  <div style="max-width: 560px; margin: 40px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #52A097 0%, #39D2C0 100%); padding: 28px 32px; color: white; text-align: center;">
      <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.85; margin-bottom: 4px;">MomRise Creator Program</div>
      <h1 style="margin: 0; font-size: 22px; font-weight: 700;">You just earned ${esc(amountStr)}</h1>
      ${sourceLine ? `<div style="margin-top: 6px; opacity: 0.95;">${sourceLine.replace(/color: #6B7280/g, 'color: rgba(255,255,255,0.9)')}</div>` : ''}
    </div>
    <div style="padding: 28px 32px;">
      <p style="margin: 0 0 16px; font-size: 16px; color: #1F2937;">Hey ${esc(firstName)},</p>
      <p style="margin: 0 0 16px; font-size: 16px; color: #1F2937;">A new subscription was credited to your code <strong style="color: #2A6F67;">${esc(creatorCode)}</strong>. Your share, <strong>${esc(amountStr)}</strong>, has been added to your pending balance.</p>
      <p style="margin: 0 0 8px; font-size: 14px; color: #6B7280;">You get paid when we get paid — Apple deposits subscription revenue to MomRise about a month after it's charged, and your share goes out on the next monthly payout run ($25 minimum). This earning pays out on <strong style="color: #2A6F67;">${esc(eligibleDate)}</strong>.</p>
      <div style="text-align: center;">
        <a href="https://momrise.app/creator/" style="display: inline-block; background: #52A097; color: white; padding: 12px 24px; border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 15px;">Open creator dashboard →</a>
      </div>
      <p style="margin: 22px 0 0; font-size: 13px; color: #6B7280; text-align: center;">Trying to figure out what content actually drives codes? Our <a href="https://momrise.app/creator/playbook/" style="color: #52A097; font-weight: 500;">creator playbook</a> has the data-backed answers.</p>
    </div>
    <div style="padding: 12px 32px 24px; text-align: center; font-size: 12px; color: #9CA3AF;">
      You're getting this because you have an active creator account on MomRise.
    </div>
  </div>
</body>
</html>`;
}

// ── Notify followers when a creator publishes content ─────────────────
// Triggered on creator_content create (e.g. a published meal plan). Emails
// the creator's followers (users whose active_creator_ref points at the
// creator), skipping anyone who has turned creator emails off. Every email
// carries a one-click unsubscribe link.
exports.notifyFollowersOnPublish = onDocumentCreated(
  {
    document: 'creator_content/{id}',
    secrets: [sendgridApiKey],
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const content = snap.data();
    if (content.is_active === false) return;

    const creatorRef = content.creator_ref;
    if (!creatorRef) return;

    const db = getFirestore();
    const creatorSnap = await creatorRef.get();
    if (!creatorSnap.exists) return;
    const creatorName = creatorSnap.data().name || 'A creator you follow';

    const followersSnap = await db
      .collection('users')
      .where('active_creator_ref', '==', creatorRef)
      .get();
    if (followersSnap.empty) return;

    sgMail.setApiKey(sendgridApiKey.value().replace(/[\s\r\n]+/g, ''));
    const title =
      content.title && content.title.trim()
        ? content.title.trim()
        : 'a new meal plan';

    let sent = 0;
    for (const doc of followersSnap.docs) {
      const d = doc.data();
      if (d.creator_email_notifications === false) continue; // opted out
      const to = d.email;
      if (!to) continue;
      const unsubUrl =
        `https://us-central1-parenting-plus-7szrif.cloudfunctions.net/unsubscribeCreatorEmails?u=${doc.id}`;
      try {
        await sgMail.send({
          to,
          from: sendgridFromEmail.value(),
          subject: `${creatorName} just shared something new on MomRise 🍽️`,
          trackingSettings: {
            clickTracking: { enable: false, enableText: false },
            openTracking: { enable: false },
          },
          html: `<div style="font-family: -apple-system, Segoe UI, Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; color: #333;">
  <h2 style="margin: 0 0 12px; color: #5D4E60;">${creatorName} just shared "${title}"</h2>
  <p style="margin: 0 0 20px; color: #555;">Open MomRise to see their latest recipes and meal plan.</p>
  <a href="https://momrise.app" style="display: inline-block; background: #52A097; color: #fff; text-decoration: none; padding: 12px 22px; border-radius: 10px; font-weight: 600;">Open MomRise</a>
  <p style="margin: 28px 0 0; font-size: 12px; color: #999;">You're getting this because you follow ${creatorName} on MomRise. <a href="${unsubUrl}" style="color: #999;">Unsubscribe from creator updates</a>.</p>
</div>`,
        });
        sent++;
      } catch (err) {
        console.warn(`[publish-notify] send failed for ${to}: ${err.message}`);
      }
    }
    console.log(
      `[publish-notify] "${title}" by ${creatorName}: emailed ${sent} follower(s)`,
    );
  },
);

// One-click unsubscribe from creator update emails. Sets a flag on the user
// doc; identified by uid in the link (low-risk for this email type).
exports.unsubscribeCreatorEmails = onRequest({ cors: true }, async (request, response) => {
  const uid = String(request.query.u || '').trim();
  if (!uid) {
    response.status(400).send('Invalid unsubscribe link.');
    return;
  }
  try {
    const db = getFirestore();
    await db.collection('users').doc(uid).set(
      { creator_email_notifications: false },
      { merge: true },
    );
    response.set('Content-Type', 'text/html');
    response.send(
      '<div style="font-family: sans-serif; text-align: center; padding: 60px 20px;"><h2>Unsubscribed</h2><p>You won\'t receive creator update emails anymore. You can re-enable them in the app\'s notification settings.</p></div>',
    );
  } catch (e) {
    console.error('unsubscribeCreatorEmails failed', e);
    response.status(500).send('Something went wrong. Please try again.');
  }
});
