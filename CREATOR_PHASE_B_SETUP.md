# Creator Phase B — App Store Connect setup

This is the user-side configuration to wire up the iOS revenue → creator earnings pipeline. The code is in place (`functions/apple_iap_functions.js` + `setActiveCreatorCode` callable + `applicationUserName` in IAP service). What's left is connecting App Store Connect to the webhook we just deployed.

## What this enables

When a user enters Haley's creator code and subscribes via Apple IAP:

1. App passes a UUID (`apple_app_account_token`) on the purchase.
2. Apple processes the payment and sends a **Server-to-Server Notification V2** to our Cloud Function `appleNotification`.
3. The function verifies the JWS signature (using Apple Root CA G3), reads the UUID, looks up the Firebase user, reads `active_creator_code`, and creates a `creator_earnings` row at 50%.
4. Refunds create clawback rows automatically.
5. The existing monthly payout runner (`runCreatorPayouts`) sweeps those rows on the 10th of each month, after a 45-day holdback.

## Setup steps

### 1. Deploy Cloud Functions

```bash
cd functions
npm install              # ensures @apple/app-store-server-library is present
firebase deploy --only functions:appleNotification,functions:setActiveCreatorCode
```

After deploy, copy the function URL — it should be:
```
https://us-central1-parenting-plus-7szrif.cloudfunctions.net/appleNotification
```

### 2. App Store Connect → enable Server Notifications V2

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. **My Apps → MomRise → App Information → App Store Server Notifications**
3. In the **Production Server URL** field, paste:
   ```
   https://us-central1-parenting-plus-7szrif.cloudfunctions.net/appleNotification
   ```
4. In **Sandbox Server URL**, paste the **same URL** — our webhook routes by the `environment` field in the payload so one endpoint serves both.
5. **Version**: select **Version 2 Notifications**.
6. Click **Save**.

### 3. Verify the webhook with the "Request a Test Notification" button

App Store Connect has a built-in test endpoint:

1. Same page as above, click **Request a Test Notification** (small button near the URL fields).
2. Apple sends a `TEST` notification type to your URL.
3. Check Firebase Functions logs:
   ```bash
   firebase functions:log --only appleNotification --limit 20
   ```
   You should see `[apple_iap] TEST uuid=<some-uuid>` followed by `OK`.
4. If you see a 500, the most likely culprit is the bundled root cert (`functions/apple_root_ca_g3.cer`) — verify it's been deployed.

### 4. Test end-to-end with a sandbox subscription

1. Build TestFlight version with the new IAP service (`apple_app_account_token` UUID write).
2. In Settings → Add Creator Code → enter a test creator's code.
3. Tap the paywall → subscribe via sandbox.
4. Within ~5 minutes you should see in Firebase Functions logs:
   ```
   [apple_iap] SUBSCRIBED/INITIAL_BUY uuid=...
   [apple_iap] earning recorded: tx=... creator=... gross=699¢ creator=350¢
   ```
5. Confirm a new doc in `creator_earnings` with `source: 'apple_iap'`, `kind: 'earning'`, and `payout_status: 'pending'`.
6. The creator's dashboard should show the pending amount.

### 5. Confirm refund clawback

1. From sandbox tester account in App Store Connect → request refund on the test purchase.
2. Apple sends a `REFUND` notification.
3. Logs should show: `[apple_iap] clawback recorded: tx=...`.
4. A second `creator_earnings` doc appears with `kind: 'clawback'` and negative cents.

## What this does NOT cover

- **Branch.io deferred deep link (Phase C)** — without this, attribution still requires manual code entry from the user. Phase B works fine without C; it just means the conversion funnel is lossier.
- **Creators not yet Connect-onboarded** — earnings are silently skipped (logged with `not onboarded`) until the creator finishes Stripe Connect setup. Reasonable default; the alternative (queuing) adds complexity.
- **Multi-currency** — currently assumes USD. Apple's `currency` field is captured on each row, but the payout runner doesn't yet handle FX. Fine while we're US-only.

## Lifecycle notes

- **Idempotency**: every notification carries a `notificationUUID`. We log it in `apple_notifications_seen/{uuid}` and skip duplicates. Apple retries failing notifications for ~3 days with exponential backoff.
- **Race with the app-side `_markSubscribed`**: the app writes `subscription_status: 'active'` on receipt; the webhook writes `creator_earnings`. These are independent — neither blocks the other.
- **`appAccountToken` not present**: logged as warning, no earning row. This happens for users who installed before Phase B shipped (no UUID in their user doc yet). Once they re-subscribe (renewal), the token gets attached.

## Related files

- `functions/apple_iap_functions.js` — webhook + earning/clawback helpers
- `functions/apple_root_ca_g3.cer` — Apple's signing root, vendored
- `functions/index.js` — registers `appleNotification` export
- `lib/custom_code/actions/iap_service.dart` — sets `applicationUserName = uuid`
