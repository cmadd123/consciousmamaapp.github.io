# Premium-Exempt List — MomRise

Hand-picked Firebase users who get free-forever premium access (skip
the 7-day trial gate, skip the paywall, never see "Subscribe").

Used for: founders, reviewers, beta testers, influencers, family.

---

## How it works

Two places in the app check whether a user is exempt:

- **`hasActiveSubscription()`** in `lib/custom_code/actions/stripe_service.dart`
  — `isUserPremiumExempt()` runs first and short-circuits to `true`
  before reading subscription state.
- **`_checkFreeTrialExpiry()`** in `lib/v2/home_hybrid/home_hybrid_widget.dart`
  — bypasses the trial-expired paywall when exempt.

The check itself (`isUserPremiumExempt` in `stripe_service.dart`) reads
from a Firestore collection called **`premium_exempt`**. The doc ID
can be either:

1. **The user's UID** (most bulletproof — survives email changes,
   works even when Apple Sign-In gives back a `@privaterelay.appleid.com`
   relay email).
2. **The user's email address** (lowercased — easiest to add before
   the user has even signed up).

Either match grants permanent premium. Failed lookups (Firestore
outage, missing doc) silently fall back to the normal subscription
check, so an outage can't strip access from a real paying customer.

---

## Adding an email — Firebase Console (RECOMMENDED, 30 sec / email)

1. [Firebase Console](https://console.firebase.google.com) → project
   **parenting-plus-7szrif** → **Firestore Database**.
2. Find or create the collection **`premium_exempt`** at the top level.
3. **Add document** →
   - **Document ID:** the email, all-lowercase
     (e.g. `ashanator92@gmail.com`)
   - Add one field: `added_at` (timestamp) → click the clock icon to
     auto-fill now. *(Optional — the doc just needs to exist; this is
     for your own audit trail.)*
   - **Save**.

That's it. Next time that user opens the app, the gate sees the doc
and treats them as a paying subscriber.

---

## Adding by UID (for Apple Sign-In + Hide My Email)

Use this when a tester signed in with Apple and toggled "Hide My
Email" on. Apple gives Firebase a relay address like
`xyz@privaterelay.appleid.com` instead of the real one, so an
email-keyed doc won't match.

1. Firebase Console → **Authentication** → find the user → copy their
   **User UID**.
2. Same flow as above, but **Document ID = the UID** (e.g.
   `abc123XYZuid...`).
3. Save.

---

## Removing an email

Same place — delete the doc from the `premium_exempt` collection. The
app re-checks on every premium gate, so access disappears on the next
gate evaluation (typically the next app open).

---

## Initial launch list (11 emails — TestFlight internal testers)

Paste these as doc IDs in the `premium_exempt` collection:

```
ashanator92@gmail.com
audreyrsamuelson@gmail.com
collinjmaddox@gmail.com
dls4christ17@gmail.com
nikkizmuller@gmail.com
caranw12@gmail.com
haley.hostetter@gmail.com
karilynne87@yahoo.com
jessrobertss@icloud.com
h.medlin03@gmail.com
jennifer.hostetter@gmail.com
```

Note: `jessrobertss@icloud.com` could be on Apple Sign-In + Hide My
Email. If exempt doesn't take effect after she signs in, fall back
to the UID method (see above).

---

## Firestore rules

Add this rule to `firestore.rules` so the app can read the collection
but only an admin can write to it:

```js
match /premium_exempt/{docId} {
  allow read: if request.auth != null;
  allow write: if false;  // Admin-only via console or service account
}
```

Without this, default-locked rules will block the app from reading
the collection and `isUserPremiumExempt()` will silently return false
for everyone.

---

## Optional: Batch-add via Node script

If the list grows past ~30 and you want to bulk-add from a CSV,
there's a `firebase-admin` dependency already in `firebase/functions/`.
A script like this in `firebase/functions/seed-premium-exempt.js`
would do the trick:

```js
const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.cert(require("./service-account.json")),
});
const db = admin.firestore();

const emails = [
  // paste lowercased emails here, one per line
];

(async () => {
  for (const email of emails) {
    await db.collection("premium_exempt").doc(email.trim().toLowerCase()).set({
      added_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("✓", email);
  }
  process.exit(0);
})();
```

Service account JSON: Firebase Console → Project settings → Service
accounts → Generate new private key. Save as
`firebase/functions/service-account.json` and add it to
`.gitignore` if not already.

Run with `node firebase/functions/seed-premium-exempt.js`.

For 11 emails the Console UI is faster; the script pays off around
50+.
