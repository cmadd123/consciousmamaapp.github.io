# Rollout: paywall lockdown + OpenAI key removal

Branch `security-paywall-openai`. Two holes fixed:

1. **Self-grantable premium.** `firestore.rules` let any user write their own `users/{uid}`, including `subscription_status`, `free_trial_start`, `subscription_id`, `stripe_customer_id`, `is_comped`, … so anyone could unlock premium. The app itself wrote `subscription_status: 'active'` after a store purchase, with no receipt check.
2. **OpenAI key shipped to every client.** The key came from Remote Config (`openai_api_key`) and the app called `api.openai.com` directly. Anyone with the app could extract it.

> **Never run a bare `firebase deploy`.** `firebase.json` also deploys `remoteconfig.template.json`, which holds a placeholder `openai_api_key` (plus `stripe_publishable_key` only). A bare deploy would overwrite live Remote Config, break the OpenAI calls in old app versions, and wipe the other live params (Instacart, Walmart, …). Always use `--only`.

---

## What changed

### Entitlements (server-write-only)

| Where | Change |
|---|---|
| `functions/entitlements.js` (new) | `verifyStorePurchase` callable: verifies an Apple purchase (StoreKit 2 signed transaction, checked offline against the bundled Apple root CA; StoreKit 1 app receipt via `/verifyReceipt` + shared secret) or a Google Play purchase (Android Publisher `purchases.subscriptionsv2.get`, default service account) and only then writes `subscription_status` etc. It checks the bundle/package, the product id, expiry/revocation, and that the store's account token matches the user's `apple_app_account_token`. It also binds each store subscription to one Firebase account (`store_purchase_bindings/`). |
| | `auditUserEntitlementWrites` trigger on `users/{uid}`. (a) Interim tripwire: any change to an entitlement field that wasn't made by a server write (server writes always bump `entitlement_verified_at`) is logged to `entitlement_audit/`. Legacy Android writes are re-verified against Google Play and stamped if valid. `ENTITLEMENT_TRIGGER_MODE = 'audit'` by default; `'enforce'` also reverts the write. (b) Stamps `free_trial_start` on the server when `onboarding_completed` flips to true without one. |
| | `refreshStoreEntitlements` (daily, 04:00 Central): re-verifies Google Play subscriptions whose verified expiry has passed. |
| | `STORE_DOWNGRADE_ON_EXPIRY = false`: expiries and refunds (Apple webhook + Play refresh) are only **logged** for now. That matches today's behaviour, where store users stay "active" forever once the app has written it. Flip it to `true` once the dry-run logs look right. |
| `functions/apple_iap_functions.js` | The App Store Server Notifications webhook now also syncs entitlement: SUBSCRIBED / DID_RENEW / OFFER_REDEEMED set the user active with a new expiry. EXPIRED / REVOKE / REFUND are dry-run as above. It exports `getVerifier` for reuse. |
| `functions/stripe_functions.js`, `functions/index.js` | Every server write of `subscription_status` / `stripe_customer_id` now also sets `entitlement_verified_at` (the "server write" marker). **`stripeWebhook` now fails closed** when `STRIPE_WEBHOOK_SECRET` is empty. Before, it accepted unsigned bodies, which was a second premium bypass. |
| `firestore.rules` | `users/{uid}`: clients can't create, change or delete any entitlement field (list in `entitlementFields()`, kept in sync with `PROTECTED_USER_FIELDS`). `free_trial_start` may be set **once**, and only to `request.time` (= `FieldValue.serverTimestamp()`, which is what the app already sends), so the existing onboarding code keeps working. `apple_app_account_token` is write-once. Client delete of the users doc is denied (the app never does it; `onUserDeleted` handles it), which also blocks a delete-and-recreate that would reset the trial. `premium_exempt`: `get` is allowed only for your own uid or email doc. `list` is denied (before, any user could list every exempt email). |
| `firestore.indexes.json` | Composite index `users(subscription_source, subscription_status, subscription_expires_at)` for the daily refresh. |
| `lib/custom_code/actions/iap_service.dart` | `_markSubscribed` no longer writes Firestore. It calls `verifyStorePurchase` with `verificationData.serverVerificationData`. The purchase is still completed/acknowledged afterwards. If verification fails, Restore Purchases retries it. |

**Why `free_trial_start == request.time` instead of moving the trial to a server trigger.** Old and new app versions already write `FieldValue.serverTimestamp()` exactly once, so the rule needs no client change and closes the reset and back-date hole. The trigger only covers the remaining gap: a user who completes onboarding but never sets it.

### OpenAI key removed from the client

| Where | Change |
|---|---|
| `functions/ai_proxy.js` (new) | `aiGenerate` callable. It requires Firebase Auth and allows only a fixed set of tasks: `appLearningPath`, `appSkillCurriculum`, `appActivityIdeas`, `appIngredientMatch`, `appChat`. The server owns the system prompts, model, temperature, max_tokens and JSON mode. Each task has a prompt-size cap. Each user gets per-task hourly and daily limits (`ai_usage/{uid}`). Response: `{content}`, the same string the app used to read from `choices[0].message.content`. App Check is **not** enforced, because the app doesn't activate App Check yet. Set `ENFORCE_APP_CHECK = true` once it does (see `FIREBASE_APP_CHECK_SETUP.md`). |
| `functions/llm_router.js` | New task profiles that keep the **same primary model and params** the app used (gpt-4o-mini, or gpt-4o for skill curriculum), with Anthropic as fallback only. Adds `gpt-4o`, multi-turn `messages`, and JSON mode (OpenAI `response_format`; Anthropic output has its code fences stripped). Ingredient matches are cached for 30 days. |
| `lib/backend/cloud_functions/ai_proxy.dart` (new) | `callAiProxy(task, …)` wrapper around `cloud_functions`. |
| `build_learning_path.dart`, `generate_skill_curriculum.dart`, `genrate_a_i_activity.dart`, `check_ingredients_match.dart` | These call `callAiProxy`. Prompts and response parsing are unchanged. |
| `lib/v1/chat/ai_chat_completion/ai_chat_completion_widget.dart` | The legacy chat uses `aiGenerate` (`appChat`). The reply now arrives in one piece instead of streaming. |
| `lib/backend/api_requests/api_calls.dart` | `OpenAiCustomGroup` calls are inert stubs (HTTP 410, no network) so the unrouted legacy assistant widget still compiles. |
| `lib/app_state.dart`, `lib/main.dart` | `openAiKey` is gone. `initializeOpenAiKey()` becomes `initializeRemoteConfig()`, which still runs fetch-and-activate for the other keys. |

---

## Manual steps for Collin (do these before step 1)

1. **Apple shared secret** (needed only for the StoreKit 1 receipt fallback, but the function won't deploy without it). In App Store Connect, open MomRise → App Information → **App-Specific Shared Secret** → Manage → Generate. Then run:
   ```
   firebase functions:secrets:set APPLE_IAP_SHARED_SECRET --project parenting-plus-7szrif
   ```
2. **Google Play API access.**
   - Enable the API:
     ```
     gcloud services enable androidpublisher.googleapis.com --project parenting-plus-7szrif
     ```
     Or use Cloud Console → APIs → "Google Play Android Developer API" → Enable.
   - Find the runtime service account. For 2nd-gen functions this is the Compute default SA, `<PROJECT_NUMBER>-compute@developer.gserviceaccount.com`. Confirm it in Cloud Console → Cloud Run → `verifystorepurchase` → Security, after the first deploy.
   - In Play Console → **Users and permissions** → Invite new users, enter that service-account email. Under App permissions, add MomRise with **View app information**, **View financial data, orders and cancellation survey responses**, and **Manage orders and subscriptions**. Permissions can take up to ~24 h to propagate. Until then Android verification fails with 401/403 in the logs.
3. **Stripe webhook secret.** Check that it's set (non-empty):
   ```
   firebase functions:secrets:access STRIPE_WEBHOOK_SECRET --project parenting-plus-7szrif
   ```
   If it's empty, set it from Stripe Dashboard → Developers → Webhooks → the endpoint → Signing secret. Otherwise the hardened webhook rejects every event.
4. **App Store Server Notifications** must already point at `appleNotification` (Production and Sandbox URLs). Leave it as is.

## Deploy order (staged rollout)

Old app versions write `subscription_status` from the client. If the rules shipped first, purchases made in those versions would never unlock. Order:

**Step 1: server (safe immediately; old apps keep working)**
```
cd functions && npm ci && cd ..
firebase deploy --only firestore:indexes --project parenting-plus-7szrif
firebase deploy --only functions --project parenting-plus-7szrif
```
Wait for the users index to finish building (Console → Firestore → Indexes) before the first 04:00 refresh run.

**Step 2: app release.** Ship the new app build (both stores). From then on, new purchases go through `verifyStorePurchase` and AI goes through `aiGenerate`.

**Interim (between steps 2 and 3).** Watch:
- `entitlement_audit` (Firestore console). Rows are client entitlement writes: old builds buying on iOS (expected), or tampering (`grants_premium: true` with no store purchase).
- `firebase functions:log --only verifyStorePurchase,aiGenerate,auditUserEntitlementWrites`
- Adoption of the new version (Analytics → app version). There is no forced-update mechanism in the app, so the long tail of old installs never fully drains. Pick a threshold (for example 90–95% of active users on the new build), or add a min-version gate in a follow-up release.

Recommendation: keep the trigger in `'audit'` mode. `'enforce'` would also revert legitimate purchases from old iOS builds, which can't be verified from the bare transaction id they store (that would need App Store Server API credentials). The audit log plus a reasonably quick step 3 is the better trade.

**Step 3: rules (after adoption)**
```
firebase deploy --only firestore:rules --project parenting-plus-7szrif
```
After this, users still on an old build can't unlock premium by buying in-app. Their store purchase goes through, but the client write is denied. Mitigation: Apple's `SUBSCRIBED` webhook still activates iOS users (if their build set `appAccountToken`), and for Android users, updating the app and tapping Restore fixes it. Expect a few support emails. Restore on the new build fixes them all.

**Step 4: OpenAI key cleanup (after old builds are gone, can run in parallel with step 3)**
1. Firebase Console → Remote Config → delete the `openai_api_key` parameter → Publish. Do it in the Console; don't deploy the template file.
2. **Rotate the key.** The current key has shipped inside every app install and must be treated as leaked. In the OpenAI dashboard → API keys, create a new key, then:
   ```
   firebase functions:secrets:set OPENAI_API_KEY --project parenting-plus-7szrif
   firebase deploy --only functions --project parenting-plus-7szrif
   ```
   Then **revoke the old key** in the OpenAI dashboard. The server already reads `OPENAI_API_KEY` from Secret Manager, so make sure it holds the new key before you revoke. If the server and the Remote Config key are currently the same key, rotate the server secret first.
3. Optional: remove `openai_api_key` from `remoteconfig.template.json`.

## Optional follow-ups (not in this change)
- Set `STORE_DOWNGRADE_ON_EXPIRY = true` (`functions/entitlements.js`) once the dry-run log lines (`(dry-run) would expire`) look right, so expired or refunded store subs actually lose premium.
- Google Play Real-Time Developer Notifications (Pub/Sub) instead of the daily refresh.
- Activate App Check in `main.dart`, then set `ENFORCE_APP_CHECK = true` in `ai_proxy.js`.
- Exempt-by-email still trusts the Auth email even when it's unverified (email/password signup). Consider requiring `request.auth.token.email_verified == true` in the `premium_exempt` rule, after checking that no comped user relies on an unverified email.
- Instacart / Walmart keys are also delivered via Remote Config. Same class of exposure, if those are secret keys.
- `OpneAiCloudFunctionCall` points at an external Cloud Run service (`my-streaming-service-…run.app/streamOpenAIResponse`) with no auth header. If that service is still deployed and holds an OpenAI key, it's an open proxy. It isn't called anywhere in `lib/`, so shut it down.

---

## How to test

### Firestore rules (emulator)
`rules-tests/users_entitlements.test.js` covers these cases:

- A normal profile create or update is allowed.
- A create with `subscription_status` is denied.
- Each protected field (status, plan, source, `subscription_id`, `stripe_customer_id`, `is_comped`, `current_period_end`, store ids, the marker) is denied when written by the client.
- The old `_markSubscribed` merge-set is denied.
- `free_trial_start = serverTimestamp()` is allowed once. A back-dated value, a reset, or a delete is denied.
- Re-writing an unchanged entitlement value is allowed.
- `apple_app_account_token` can be set once and not changed.
- Deleting the users doc is denied, and so is reading another user's doc.
- `premium_exempt`: get of your own uid or email is allowed. Get of another email, a list, or a write is denied.
- `store_purchase_bindings`, `entitlement_audit` and `ai_usage` can't be read or written by clients.

Needs the Firebase CLI + Java:
```
cd rules-tests
npm install
npm run test:emulator        # wraps: firebase emulators:exec --only firestore "npm test"
```
These tests have **not been run**: the emulator isn't available on the machine where this change was written.

### Functions
- **Apple sandbox:** a TestFlight build with a sandbox tester. Buy monthly, and check that `users/{uid}` gets `subscription_source: apple_iap`, `subscription_expires_at`, `entitlement_verified_at`, and that the log shows `verified apple_iap … env=Sandbox`. Restore on a second device signed into a *different* MomRise account should be refused ("linked to another MomRise account").
- **Google:** an internal-testing track with a license tester. Buy, and check `subscription_source: google_play` and `store_environment: Sandbox` (test purchase). If you get 401/403, the Play Console permissions haven't propagated yet.
- **Forged purchase:** call `verifyStorePurchase` with junk `verificationData`. Expect `permission-denied`.
- **Tamper attempt before the rules ship:** with a test account, write `subscription_status: 'active'` from a client (or the console as that user via the REST API). An `entitlement_audit` row should appear. After step 3, the same write should fail with PERMISSION_DENIED.
- **AI:** create a learning path, a skill path, AI activity ideas, add overlapping grocery items (ingredient match), and use the legacy chat. Output should look the same as before. `firebase functions:log --only aiGenerate` should show no errors. Hitting a task's hourly limit returns "You've reached the limit…". Calling while signed out should return `unauthenticated`.
- **Stripe:** send a test event from the Stripe dashboard and confirm a 200 response (proves the webhook secret is set).

### Untested
- No Dart was compiled. Flutter isn't installed here, so `flutter analyze` and a device build must be run before release.
- No function ran against real Apple, Google, OpenAI or Firestore. Only local validation paths were smoke-tested: unauthenticated calls, a bad platform, a forged JWS rejected, an unknown AI task, oversize prompts.
- The rules tests above have not been run.
- Which value `serverVerificationData` holds on iOS (a StoreKit 2 JWS or a StoreKit 1 receipt) depends on the `in_app_purchase_storekit` mode. The server handles both, but confirm with a sandbox purchase.
