#!/usr/bin/env node
// One-time helper to obtain a Pinterest refresh token for the auto-pin engine.
// Nothing is stored in the repo — you paste the resulting refresh token to
// whoever sets the Secret Manager secret.
//
// Prereqs (from your Pinterest developer app):
//   export PINTEREST_APP_ID=...          # the app's client id
//   export PINTEREST_APP_SECRET=...      # the app's client secret
//   export PINTEREST_REDIRECT="https://momrise.app/oauth/pinterest/"   # must be
//                                        # registered in the app's redirect URIs
//
// Flow:
//   1) node scripts/pinterest-oauth.js url
//        → open the printed URL, authorize; you land on the redirect page,
//          which shows an authorization code.
//   2) node scripts/pinterest-oauth.js exchange <code>
//        → prints your refresh token (and a quick token sanity check).
//
// Scopes requested: boards:read, pins:write (posting to your own boards).

const APP_ID = process.env.PINTEREST_APP_ID;
const APP_SECRET = process.env.PINTEREST_APP_SECRET;
const REDIRECT = process.env.PINTEREST_REDIRECT || 'https://momrise.app/oauth/pinterest/';
const SCOPES = 'boards:read,pins:write';
const API = 'https://api.pinterest.com/v5';

function need(v, name) {
  if (!v) { console.error(`Missing env ${name}. See the header of this file.`); process.exit(1); }
}

async function main() {
  const cmd = process.argv[2];

  if (cmd === 'url') {
    need(APP_ID, 'PINTEREST_APP_ID');
    const u = new URL('https://www.pinterest.com/oauth/');
    u.searchParams.set('client_id', APP_ID);
    u.searchParams.set('redirect_uri', REDIRECT);
    u.searchParams.set('response_type', 'code');
    u.searchParams.set('scope', SCOPES);
    u.searchParams.set('state', 'momrise');
    console.log('\nOpen this URL, authorize, then copy the code from the redirect page:\n');
    console.log(u.toString() + '\n');
    return;
  }

  if (cmd === 'exchange') {
    need(APP_ID, 'PINTEREST_APP_ID');
    need(APP_SECRET, 'PINTEREST_APP_SECRET');
    const code = process.argv[3];
    need(code, '<code> argument');
    const basic = Buffer.from(`${APP_ID}:${APP_SECRET}`).toString('base64');
    const res = await fetch(`${API}/oauth/token`, {
      method: 'POST',
      headers: { Authorization: `Basic ${basic}`, 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'authorization_code', code, redirect_uri: REDIRECT }),
    });
    const data = await res.json();
    if (!res.ok) {
      console.error(`\nExchange failed (${res.status}):`, JSON.stringify(data, null, 2));
      console.error('\nCommon causes: code already used/expired (get a fresh one), or redirect_uri mismatch.');
      process.exit(1);
    }
    console.log('\n✅ Success. Store the REFRESH token as the Secret Manager secret PINTEREST_REFRESH_TOKEN:\n');
    console.log('REFRESH TOKEN:\n' + data.refresh_token + '\n');
    console.log(`(access token expires in ${data.expires_in}s; the engine refreshes it automatically)\n`);

    // Quick sanity check: list boards with the fresh access token.
    try {
      const b = await fetch(`${API}/boards?page_size=25`, { headers: { Authorization: `Bearer ${data.access_token}` } });
      const bj = await b.json();
      if (b.ok && Array.isArray(bj.items)) {
        console.log('Your boards (use these IDs in config/pinterest.boards):');
        for (const brd of bj.items) console.log(`  - ${brd.id}  ${brd.name}`);
        console.log('');
      }
    } catch { /* non-fatal */ }
    return;
  }

  console.error('Usage:\n  node scripts/pinterest-oauth.js url\n  node scripts/pinterest-oauth.js exchange <code>');
  process.exit(1);
}

main().catch((e) => { console.error(e); process.exit(1); });
