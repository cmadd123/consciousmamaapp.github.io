# Pinterest Auto-Pin — Activation Checklist

The engine is built and committed but **inert** until (a) the secrets are set,
(b) the function is deployed, and (c) `config/pinterest.enabled` is flipped to
`true`. Deploying early is safe — with `enabled: false` it does nothing.

Code:
- `functions/pinterest_autopin.js` — scheduled drip (`pinterestAutoPin`) + a
  manual test trigger (`pinterestTestPin`, admin-only).
- `scripts/pinterest-oauth.js` — one-time refresh-token grab.
- `oauth/pinterest/` — the redirect page that shows the authorization code.

## 1. Pinterest developer app (you)
- App created at developers.pinterest.com (Personal / single-account access,
  purpose "Pin creation & scheduling").
- Register redirect URI: **`https://momrise.app/oauth/pinterest/`**
- Note the **App ID** (client id) and **App secret**.
- Create the boards you want to pin to (e.g. Easy Toddler Dinners, Sheet Pan
  Family Meals, 30-Minute Mom Recipes, …).

## 2. Get a refresh token (one-time)
```bash
export PINTEREST_APP_ID=xxxx
export PINTEREST_APP_SECRET=xxxx
export PINTEREST_REDIRECT="https://momrise.app/oauth/pinterest/"

node scripts/pinterest-oauth.js url          # open the URL, authorize
node scripts/pinterest-oauth.js exchange <code>   # prints the refresh token + your board IDs
```

## 3. Set the secrets (Secret Manager)
```bash
firebase functions:secrets:set PINTEREST_APP_ID       # paste the client id
firebase functions:secrets:set PINTEREST_APP_SECRET   # paste the app secret
firebase functions:secrets:set PINTEREST_REFRESH_TOKEN# paste the refresh token
```

## 4. Configure (Firestore doc `config/pinterest`)
Create the doc with your real board IDs (from step 2):
```json
{
  "enabled": false,
  "boards": [
    { "id": "PUT_BOARD_ID", "slug": "easy-toddler-dinners", "name": "Easy Toddler Dinners" },
    { "id": "PUT_BOARD_ID", "slug": "30-minute-mom-recipes", "name": "30-Minute Mom Recipes" }
  ],
  "pins_per_run": 2,
  "min_days_between_repins": 30
}
```

## 5. Deploy
```bash
firebase deploy --only functions:pinterestAutoPin,functions:pinterestTestPin
```

## 6. Test, then go live
- With `enabled: false`, run one pin manually via the callable `pinterestTestPin`
  ({ count: 1 })… actually set `enabled: true` first (the batch no-ops while
  disabled), verify one pin lands on the right board, links back with
  `?src=pinterest`, and looks right.
- Then leave `enabled: true`. The schedule drips at 9am/1pm/5pm ET on weekdays,
  `pins_per_run` each (default 2 → ~6/weekday). Tune cadence in the schedule and
  volume in the config.

## ⚠️ Access tier: Trial vs. Standard
Pinterest **Trial access cannot create pins in production** (only against the
sandbox). Creating real pins requires **Standard access**, which Pinterest
grants after a review. Status as of setup: secrets set, config written, scopes
correct (`boards:read,boards:write,pins:read,pins:write`), 60-pin queue ready,
and a production pin was accepted by the API up to the access check (error 29:
"Apps with Trial access may not create Pins in production"). So the ONLY thing
blocking go-live is the Standard-access upgrade.

To apply: developers.pinterest.com → your app → request **Standard/Production
access**. Once granted → `firebase deploy --only functions:pinterestAutoPin,
functions:pinterestTestPin` and set `config/pinterest.enabled = true`.

## Guardrails / notes
- **ToS-safe drip**, never a flood — Pinterest suspends spammy automation.
- Content source is curated recipes with a branded pin image
  (`magazine_pin_url`). Run `scripts/generate-pin-images.js` +
  `scripts/upload-pin-images.js` first so recipes have pin images.
- Re-pins are throttled by `min_days_between_repins`.
- To pause instantly: set `config/pinterest.enabled = false` (no redeploy).
- Comparison + meal-idea pins are a future add (needs pin images for those
  page types).
