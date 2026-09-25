// Approval-gated creator outreach email — send + reply ingestion.
//
// Per-sender identity: the outbound address follows whoever is logged into the
// CRM. Jill sends as jill@momrise.app from her own Gmail; Haley sends as
// haley@momrise.app from hers. Each authenticates with its own Gmail app
// password and reads its own inbox for replies.
//
// Sending: Gmail SMTP (nodemailer) using an app password, FROM the sender's
//   momrise.app alias (a verified "send as" on that Gmail account). Approval-
//   gated: the CRM builds a draft, the recruiter reviews/edits, then calls
//   sendCreatorEmail. Throttled per sender per day.
// Ingestion: IMAP (imapflow) reads EACH sender's inbox on a schedule, matches
//   replies to contacted leads by sender address, flips them to "replied", and
//   stores a snippet — so conversations surface back in the CRM. Runs every 15
//   min and is also callable on demand (checkCreatorReplies).
//
// Why SMTP/IMAP + app password over the Gmail API: Gmail API's send/read scopes
// are "sensitive" and require Google app verification for production + refresh
// tokens that expire in testing mode — both hostile to an unattended pipeline.
// App passwords don't expire and need no OAuth screen.
//
// Prereqs per sender (set by Collin), for each Gmail account below:
//   1. 2-Step Verification ON, then generate an app password.
//   2. Add the momrise.app alias as a verified "Send mail as" address
//      (Gmail Settings → Accounts → Send mail as). Google's verification email
//      forwards back via ImprovMX to that same inbox.
//   3. ImprovMX alias forwards to that Gmail (haley@→haleyjmaddox, jill@→jmaddox3902).
//   secrets: GMAIL_APP_PASSWORD_HALEY, GMAIL_APP_PASSWORD_JILL

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const nodemailer = require('nodemailer');
const { ImapFlow } = require('imapflow');
const { simpleParser } = require('mailparser');

const GMAIL_APP_PASSWORD_HALEY = defineSecret('GMAIL_APP_PASSWORD_HALEY');
const GMAIL_APP_PASSWORD_JILL = defineSecret('GMAIL_APP_PASSWORD_JILL');
const EMAIL_SECRETS = [GMAIL_APP_PASSWORD_HALEY, GMAIL_APP_PASSWORD_JILL];

// CAN-SPAM: commercial email needs a real postal address. Replace with
// MomRise's mailing address when available.
const POSTAL = 'MomRise · (mailing address pending)';

const CRM_EMAILS = ['collinjmaddox@gmail.com', 'brennanmaddox27@gmail.com', 'haley.hostetter@gmail.com', 'jmaddox3902@gmail.com'];
const DAILY_CAP = 40;   // safety ceiling on sends per sender per day

// Per-sender identity, keyed by the CRM login email. Jill gets her own address;
// everyone else (Haley + Collin/Brennan as testers) sends as Haley.
function senderFor(loginEmail) {
  const e = (loginEmail || '').toLowerCase();
  if (e === 'jmaddox3902@gmail.com') {
    return {
      id: 'jill',
      user: 'jmaddox3902@gmail.com',
      pass: () => GMAIL_APP_PASSWORD_JILL.value().trim(),
      fromEmail: 'jill@momrise.app',
      fromName: 'Jill at MomRise',
    };
  }
  return {
    id: 'haley',
    user: 'haleyjmaddox@gmail.com',
    pass: () => GMAIL_APP_PASSWORD_HALEY.value().trim(),
    fromEmail: 'haley@momrise.app',
    fromName: 'Haley at MomRise',
  };
}

// Every inbox we ingest replies from — one per real sender identity.
function allInboxes() {
  return [
    { id: 'haley', user: 'haleyjmaddox@gmail.com', pass: () => GMAIL_APP_PASSWORD_HALEY.value().trim() },
    { id: 'jill', user: 'jmaddox3902@gmail.com', pass: () => GMAIL_APP_PASSWORD_JILL.value().trim() },
  ];
}

function requireCrm(request) {
  const email = (request.auth?.token?.email || '').toLowerCase();
  if (!CRM_EMAILS.includes(email)) throw new HttpsError('permission-denied', 'CRM access required');
}

function footer() {
  return {
    text: `\n\n—\nNot the right fit? Just reply "no thanks" and I won't follow up.\n${POSTAL}`,
    html: `<br><br>—<br><span style="color:#888;font-size:12px;">Not the right fit? Just reply "no thanks" and I won't follow up.<br>${POSTAL}</span>`,
  };
}

function transporter(sender) {
  return nodemailer.createTransport({
    host: 'smtp.gmail.com', port: 465, secure: true,
    auth: { user: sender.user, pass: sender.pass() },
  });
}

exports.sendCreatorEmail = onCall(
  { secrets: EMAIL_SECRETS, timeoutSeconds: 60 },
  async (request) => {
    requireCrm(request);
    const sender = senderFor(request.auth?.token?.email);
    const { leadId, subject, body } = request.data || {};
    if (!leadId || !subject || !body) throw new HttpsError('invalid-argument', 'leadId, subject, body required');

    const db = getFirestore();
    const ref = db.collection('outreach_leads').doc(String(leadId));
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Lead not found');
    const lead = snap.data();
    if (!lead.email) throw new HttpsError('failed-precondition', 'Lead has no email address');

    // Daily throttle — per sender, to protect each account's reputation.
    const dayStart = Timestamp.fromMillis(new Date().setHours(0, 0, 0, 0));
    const sentToday = await db.collection('outreach_leads').where('last_email_at', '>=', dayStart).get();
    let mine = 0;
    sentToday.forEach((d) => { if ((d.data().sent_by || 'haley') === sender.id) mine++; });
    if (mine >= DAILY_CAP) {
      throw new HttpsError('resource-exhausted', `Daily send cap (${DAILY_CAP}) reached — try again tomorrow.`);
    }

    const f = footer();
    const textBody = String(body).trim();
    const htmlBody = textBody.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/\n/g, '<br>');
    const from = `${sender.fromName} <${sender.fromEmail}>`;
    try {
      await transporter(sender).sendMail({
        from, to: lead.email, replyTo: sender.fromEmail,
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
      sent_by: sender.id,
      sent_as: sender.fromEmail,
      emailed: true,
      updated_at: FieldValue.serverTimestamp(),
    });
    return { ok: true, sentAs: sender.fromEmail };
  },
);

// Ingest one inbox: read it, match replies to contacted leads, flip to
// "replied" with a snippet. Returns { checked, matched }.
async function ingestInbox(inbox, byEmail) {
  if (!Object.keys(byEmail).length) return { checked: 0, matched: 0 };
  const client = new ImapFlow({
    host: 'imap.gmail.com', port: 993, secure: true,
    auth: { user: inbox.user, pass: inbox.pass() },
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

// Shared ingestion across every sender inbox. A reply lands in whichever inbox
// the lead was contacted from, so we check them all and match by sender address.
async function runIngest() {
  const db = getFirestore();
  const snap = await db.collection('outreach_leads').where('status', '==', 'contacted').get();
  const byEmail = {};
  snap.forEach((d) => { const e = (d.data().email || '').toLowerCase(); if (e) byEmail[e] = d.ref; });
  if (!Object.keys(byEmail).length) return { checked: 0, matched: 0 };

  let checked = 0, matched = 0;
  for (const inbox of allInboxes()) {
    try {
      const r = await ingestInbox(inbox, byEmail);   // byEmail is drained as leads match
      checked += r.checked; matched += r.matched;
    } catch (e) {
      console.error(`[ingest] ${inbox.id} failed: ${e.message}`);
    }
  }
  return { checked, matched };
}

// Scheduled: every 15 minutes.
exports.ingestCreatorReplies = onSchedule(
  { schedule: 'every 15 minutes', secrets: EMAIL_SECRETS, timeoutSeconds: 180 },
  async () => { const r = await runIngest(); console.log(`[ingest] checked=${r.checked} matched=${r.matched}`); },
);

// On-demand: the CRM "Check replies" button.
exports.checkCreatorReplies = onCall(
  { secrets: EMAIL_SECRETS, timeoutSeconds: 180 },
  async (request) => { requireCrm(request); return runIngest(); },
);
