// Approval-gated creator outreach email — send + reply ingestion.
//
// Sending: Gmail SMTP (nodemailer) using an app password, FROM haley@momrise.app
//   (Haley's verified "send as" alias). Approval-gated: the CRM builds a draft,
//   Haley reviews/edits, then calls sendCreatorEmail. Throttled per day.
// Ingestion: IMAP (imapflow) reads Haley's inbox on a schedule, matches replies
//   to contacted leads by sender address, flips them to "replied", and stores a
//   snippet — so conversations surface back in the CRM. Runs every 15 min and
//   is also callable on demand (checkCreatorReplies).
//
// Why SMTP/IMAP + app password over the Gmail API: Gmail API's send/read scopes
// are "sensitive" and require Google app verification for production + refresh
// tokens that expire in testing mode — both hostile to an unattended pipeline.
// App passwords don't expire and need no OAuth screen.
//
// Prereqs (set by Collin):
//   secrets: GMAIL_USER (e.g. haley.hostetter@gmail.com), GMAIL_APP_PASSWORD
//   Haley's Gmail must have haley@momrise.app configured as a verified "send as"
//   alias (already done for manual sending).

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret, defineString } = require('firebase-functions/params');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const nodemailer = require('nodemailer');
const { ImapFlow } = require('imapflow');
const { simpleParser } = require('mailparser');

const GMAIL_USER = defineSecret('GMAIL_USER');
const GMAIL_APP_PASSWORD = defineSecret('GMAIL_APP_PASSWORD');
const FROM_EMAIL = defineString('OUTREACH_FROM_EMAIL', { default: 'haley@momrise.app' });
const FROM_NAME = defineString('OUTREACH_FROM_NAME', { default: 'Haley at MomRise' });
// CAN-SPAM: commercial email needs a real postal address. Set OUTREACH_POSTAL
// to MomRise's mailing address; until then a placeholder is used.
const POSTAL = defineString('OUTREACH_POSTAL', { default: 'MomRise · (set OUTREACH_POSTAL to a mailing address)' });

const CRM_EMAILS = ['collinjmaddox@gmail.com', 'brennanmaddox27@gmail.com', 'haley.hostetter@gmail.com'];
const DAILY_CAP = 40;   // safety ceiling on sends per day

function requireCrm(request) {
  const email = (request.auth?.token?.email || '').toLowerCase();
  if (!CRM_EMAILS.includes(email)) throw new HttpsError('permission-denied', 'CRM access required');
}

function footer() {
  return {
    text: `\n\n—\nNot the right fit? Just reply "no thanks" and I won't follow up.\n${POSTAL.value()}`,
    html: `<br><br>—<br><span style="color:#888;font-size:12px;">Not the right fit? Just reply "no thanks" and I won't follow up.<br>${POSTAL.value()}</span>`,
  };
}

function transporter() {
  return nodemailer.createTransport({
    host: 'smtp.gmail.com', port: 465, secure: true,
    auth: { user: GMAIL_USER.value().trim(), pass: GMAIL_APP_PASSWORD.value().trim() },
  });
}

exports.sendCreatorEmail = onCall(
  { secrets: [GMAIL_USER, GMAIL_APP_PASSWORD], timeoutSeconds: 60 },
  async (request) => {
    requireCrm(request);
    const { leadId, subject, body } = request.data || {};
    if (!leadId || !subject || !body) throw new HttpsError('invalid-argument', 'leadId, subject, body required');

    const db = getFirestore();
    const ref = db.collection('outreach_leads').doc(String(leadId));
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Lead not found');
    const lead = snap.data();
    if (!lead.email) throw new HttpsError('failed-precondition', 'Lead has no email address');

    // Daily throttle — protect sender reputation.
    const dayStart = Timestamp.fromMillis(new Date().setHours(0, 0, 0, 0));
    const sentToday = await db.collection('outreach_leads').where('last_email_at', '>=', dayStart).get();
    if (sentToday.size >= DAILY_CAP) {
      throw new HttpsError('resource-exhausted', `Daily send cap (${DAILY_CAP}) reached — try again tomorrow.`);
    }

    const f = footer();
    const textBody = String(body).trim();
    const htmlBody = textBody.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/\n/g, '<br>');
    const from = `${FROM_NAME.value()} <${FROM_EMAIL.value()}>`;
    try {
      await transporter().sendMail({
        from, to: lead.email, replyTo: FROM_EMAIL.value(),
        subject: String(subject).trim(),
        text: textBody + f.text,
        html: htmlBody + f.html,
      });
    } catch (e) {
      throw new HttpsError('internal', `Send failed: ${e.message}`);
    }

    await ref.update({
      status: lead.status === 'to_contact' ? 'contacted' : lead.status,
      last_contacted: new Date().toISOString().slice(0, 10),
      last_email_at: FieldValue.serverTimestamp(),
      last_email_subject: String(subject).trim(),
      emailed: true,
      updated_at: FieldValue.serverTimestamp(),
    });
    return { ok: true };
  },
);

// Shared ingestion: read the inbox, match replies to contacted leads, flip to
// "replied" with a snippet. Returns { checked, matched }.
async function runIngest() {
  const db = getFirestore();
  const snap = await db.collection('outreach_leads').where('status', '==', 'contacted').get();
  const byEmail = {};
  snap.forEach((d) => { const e = (d.data().email || '').toLowerCase(); if (e) byEmail[e] = d.ref; });
  if (!Object.keys(byEmail).length) return { checked: 0, matched: 0 };

  const client = new ImapFlow({
    host: 'imap.gmail.com', port: 993, secure: true,
    auth: { user: GMAIL_USER.value().trim(), pass: GMAIL_APP_PASSWORD.value().trim() },
    logger: false,
  });
  await client.connect();
  let checked = 0, matched = 0;
  const hits = [];   // { uid, ref, date, subject }
  const lock = await client.getMailboxLock('INBOX');
  try {
    const since = new Date(Date.now() - 7 * 24 * 3600 * 1000);
    for await (const msg of client.fetch({ since }, { uid: true, envelope: true, internalDate: true })) {
      checked++;
      const from = (msg.envelope?.from?.[0]?.address || '').toLowerCase();
      const ref = byEmail[from];
      if (!ref) continue;
      hits.push({ uid: msg.uid, ref, date: msg.internalDate, subject: msg.envelope?.subject || '' });
      delete byEmail[from];   // one reply per lead per run
    }
    // Fetch bodies only for matched messages, then update.
    for (const h of hits) {
      let snippet = '';
      try {
        const one = await client.fetchOne(h.uid, { source: true }, { uid: true });
        if (one?.source) { const p = await simpleParser(one.source); snippet = String(p.text || '').trim().slice(0, 600); }
      } catch (_) { /* snippet optional */ }
      await h.ref.update({
        status: 'replied',
        replied_at: h.date ? Timestamp.fromDate(new Date(h.date)) : FieldValue.serverTimestamp(),
        reply_subject: h.subject,
        reply_snippet: snippet,
        updated_at: FieldValue.serverTimestamp(),
      });
      matched++;
    }
  } finally {
    lock.release();
  }
  await client.logout();
  return { checked, matched };
}

// Scheduled: every 15 minutes.
exports.ingestCreatorReplies = onSchedule(
  { schedule: 'every 15 minutes', secrets: [GMAIL_USER, GMAIL_APP_PASSWORD], timeoutSeconds: 120 },
  async () => { const r = await runIngest(); console.log(`[ingest] checked=${r.checked} matched=${r.matched}`); },
);

// On-demand: the CRM "Check replies" button.
exports.checkCreatorReplies = onCall(
  { secrets: [GMAIL_USER, GMAIL_APP_PASSWORD], timeoutSeconds: 120 },
  async (request) => { requireCrm(request); return runIngest(); },
);
