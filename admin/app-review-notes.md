# App Store Review — Notes for Review

Paste the block below into **App Store Connect → MomRise → App Information → "Notes for Review"** (or "Review Notes" depending on UI version) when submitting MomRise 2.x for App Review.

The notes do three jobs:

1. Provide a working test creator code so the reviewer can verify the IAP attribution flow without bouncing off it.
2. Pre-emptively explain "creator codes" so the reviewer doesn't misread them as alternate-payment / external-purchase signals.
3. Confirm we follow Apple's IAP guidelines (no external payment, no price changes, native subscription management).

---

## Paste-ready block (copy from "Hello App Review team," to end)

Hello App Review team,

Thank you for reviewing MomRise. A few notes that should make the review easier — please reach out if anything is unclear.

**Test sandbox account**

Apple sandbox tester credentials are configured in App Store Connect → Users and Access → Sandbox Testers. Please use the most recently active tester to verify the In-App Purchase flow. Both monthly ($6.99/mo) and yearly ($69.99/yr) auto-renewable subscriptions are available.

**Test creator code: STONE45**

MomRise includes a creator referral program. Content creators (parenting influencers) are given unique alphanumeric codes (such as "STONE45") that they share with their followers. When a follower enters a creator's code during sign-up, on the paywall, or in Settings, the creator earns a percentage of that follower's Apple IAP subscription revenue as a commission paid through Stripe Connect.

Important points about creator codes:

- The code is purely for **internal revenue-share attribution**. It does NOT change the price the user pays.
- All payments are processed exclusively through Apple's In-App Purchase system. There are no external payment links, no discounted prices for code holders, and no external account creation.
- The code is stored on the user's MomRise account and used by our server to attribute future Apple IAP subscription revenue from that user to the creator.
- Users can enter, change, or skip a creator code at any time. Codes are completely optional.

To verify the flow:

1. Sign up for a new MomRise account (any email).
2. On the paywall, tap "Got a creator code?" — OR — in Settings, tap "Add Creator Code."
3. Enter: **STONE45**
4. Subscribe to monthly or yearly via the standard Apple IAP flow.

**Subscription management**

The "Cancel Subscription" button in Settings opens Apple's standard subscription management URL (apps.apple.com/account/subscriptions). We do not handle Apple IAP cancellations server-side, in compliance with Apple's guidance.

**Deferred attribution (privacy disclosure)**

MomRise has a small first-party deferred deep-linking feature for the creator program. When a follower visits a creator's share page on the web (momrise.app/c/{code}) and then installs the app, our server matches the web visit to the app install using a coarse device fingerprint (IP address, partial user-agent, screen size, language, timezone). This is first-party data, used only by us, only for attribution, deleted after 24 hours, and does NOT require App Tracking Transparency because we do not track users across other companies' apps or websites. This is fully documented in our Privacy Policy (https://momrise.app/privacy.html, Section 2 — "Creator code attribution data").

**Privacy Policy**

https://momrise.app/privacy.html

**Support contact**

privacy@momrise.app for privacy questions
support@momrise.app for general support
creators@momrise.app for creator program questions

Please let us know if any additional information would help with the review.

Thank you,
The MomRise team

---

## Why each section is in there

- **Test sandbox account** — Apple reviewers test IAP through their internal sandbox; they expect documented tester credentials.
- **Test creator code section** — pre-empts the most likely confusion. A reviewer seeing "creator code" in the paywall could read it as an alternate payment, a referral-discount mechanism (which Apple does NOT allow under 3.1.3(b)), or external account linking. Explicitly stating "purely internal revenue-share attribution" and "does NOT change the price the user pays" inoculates against rejection on those grounds.
- **Subscription management** — proactively confirms compliance with Apple's IAP cancellation guidance.
- **Deferred attribution** — required because Apple privacy team cross-checks the App Store Connect privacy questionnaire against actual app behavior. Disclosing the fingerprint match explicitly + framing it correctly (first-party, not ATT-required) heads off any privacy-team flag.
- **Privacy policy + support contacts** — table stakes, but reviewers do click these.

## Things NOT to put in the notes

- Mention of Stripe payment for non-Apple users (web) — irrelevant to iOS review and could draw unwanted attention
- Mention of the creator dashboard (web-only feature, not part of the iOS app surface area)
- Marketing copy — keep it operational, not promotional
- Anything that sounds defensive or apologetic

## After submission

If Apple's reviewer flags anything related to the creator code feature anyway, the response is the same as above with extra emphasis:

> "Creator codes are internal revenue-share attribution only. They do not change the price the user pays, do not grant discounts, do not unlock additional content, and do not require external account creation. All payment processing is handled exclusively through Apple's In-App Purchase system."

If they flag the deferred attribution feature, point them to Section 2 of our Privacy Policy and clarify that the data is first-party-only and not covered by Apple's tracking definition (which is specifically about linking data with third parties for advertising).
