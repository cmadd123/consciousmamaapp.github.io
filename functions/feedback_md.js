// Compile in-app reviewer notes (the `feedback` collection written by
// lib/custom_code/widgets/annotation_overlay.dart) into Markdown for review.
//
// Secret-gated (reuses BACKFILL_SECRET from functions/.env):
//   /feedbackMarkdown?secret=<SECRET>        # open notes, newest first
//   /feedbackMarkdown?secret=<SECRET>&all=1  # include resolved
//   /feedbackMarkdown?secret=<SECRET>&resolve=<id>  # mark one resolved

const { onRequest } = require('firebase-functions/v2/https');
const { defineString } = require('firebase-functions/params');
const { getFirestore } = require('firebase-admin/firestore');

const reviewSecret = defineString('BACKFILL_SECRET');

exports.feedbackMarkdown = onRequest(async (request, response) => {
  const provided = String(request.query.secret || '');
  const expected = reviewSecret.value();
  if (!expected || provided !== expected) {
    response.status(403).send('Forbidden');
    return;
  }

  const db = getFirestore();

  // Optional: mark one note resolved.
  const resolveId = String(request.query.resolve || '');
  if (resolveId) {
    try {
      await db.collection('feedback').doc(resolveId).update({
        status: 'resolved',
        resolved_at: new Date().toISOString(),
      });
      response.send(`Resolved ${resolveId}`);
    } catch (e) {
      response.status(500).send('Error: ' + e.message);
    }
    return;
  }

  const includeResolved =
    request.query.all === '1' || request.query.all === 'true';

  try {
    const snap = await db.collection('feedback').get();
    const rows = [];
    snap.forEach((d) => {
      const r = d.data();
      if (!includeResolved && r.status === 'resolved') return;
      rows.push({ id: d.id, ...r });
    });
    rows.sort((a, b) => {
      const at = a.created_at?.toMillis?.() || 0;
      const bt = b.created_at?.toMillis?.() || 0;
      return bt - at;
    });

    let md = `# MomRise — In-App Review Notes\n\n`;
    md += `${rows.length} note${rows.length === 1 ? '' : 's'}`;
    md += includeResolved ? ' (incl. resolved)' : ' (open)';
    md += ` · generated ${new Date().toISOString()}\n\n`;

    for (const r of rows) {
      const when = r.created_at?.toDate?.()
        ? r.created_at.toDate().toISOString().slice(0, 16).replace('T', ' ')
        : '';
      const who = (r.email || '').split('@')[0];
      const route = r.route ? ` · \`${r.route}\`` : '';
      const status = r.status === 'resolved' ? ' ✅' : '';
      md += `- **${(r.note || '').replace(/\n/g, ' ')}**${status}\n`;
      md += `  <sub>${who}${route} · ${when} · id:\`${r.id}\`</sub>\n\n`;
    }

    response.set('Content-Type', 'text/markdown; charset=utf-8');
    response.send(md);
  } catch (e) {
    console.error('feedbackMarkdown failed', e);
    response.status(500).send('Error: ' + e.message);
  }
});
