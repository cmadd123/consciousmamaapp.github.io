// One-off cleanup: removes a single email's premium-exempt state so the user
// becomes a normal non-subscribed account again. Used when we want to test
// the real IAP / paywall flow end-to-end with that Apple ID.
//
// What it does:
//   1. Deletes the `premium_exempt/{email}` doc so the next app build's
//      isUserPremiumExempt() check returns false.
//   2. If the user has a Firebase Auth account, clears the subscription
//      fields on their users/{uid} doc (subscription_status,
//      subscription_source, subscription_plan, subscription_updated_at)
//      so the currently-deployed build treats them as unsubscribed.
//
// What it does NOT do:
//   - Touch any Apple StoreKit transaction history — that's owned by Apple,
//     not us. The user just becomes "un-exempt"; if they make a real IAP
//     purchase, that'll flow through verifyPurchase / Apple's webhooks
//     normally.
//
// Idempotent: re-running on an already-cleaned account is a no-op.
//
// Usage:
//   node remove-from-exempt.js <service-account.json> <email>

const admin = require("firebase-admin");
const path = require("path");

const KEY_PATH = process.argv[2];
const EMAIL_RAW = process.argv[3];

if (!KEY_PATH || !EMAIL_RAW) {
  console.error("Usage: node remove-from-exempt.js <service-account.json> <email>");
  process.exit(2);
}

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(KEY_PATH))),
});
const db = admin.firestore();
const auth = admin.auth();

async function main() {
  const email = EMAIL_RAW.trim().toLowerCase();
  console.log(`Removing premium-exempt state for: ${email}`);

  // 1. Delete the exempt collection doc.
  const exemptRef = db.collection("premium_exempt").doc(email);
  const exemptSnap = await exemptRef.get();
  if (exemptSnap.exists) {
    await exemptRef.delete();
    console.log(`  ✓ Deleted premium_exempt/${email}`);
  } else {
    console.log(`  · premium_exempt/${email} did not exist (already removed)`);
  }

  // 2. Find the Auth user and clear their subscription fields, if any.
  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === "auth/user-not-found") {
      console.log(`  · No Auth user for ${email} — done.`);
      process.exit(0);
    }
    throw e;
  }

  const userRef = db.collection("users").doc(user.uid);
  const userSnap = await userRef.get();
  if (!userSnap.exists) {
    console.log(`  · users/${user.uid} doc does not exist — done.`);
    process.exit(0);
  }

  const data = userSnap.data() || {};
  const wasExempt = data.subscription_source === "exempt";

  await userRef.update({
    subscription_status: admin.firestore.FieldValue.delete(),
    subscription_source: admin.firestore.FieldValue.delete(),
    subscription_plan: admin.firestore.FieldValue.delete(),
    subscription_updated_at: admin.firestore.FieldValue.delete(),
  });
  console.log(
    `  ✓ Cleared subscription fields on users/${user.uid}` +
      (wasExempt ? " (was source=exempt)" : ` (was source=${data.subscription_source ?? "<unset>"})`)
  );

  console.log("");
  console.log("Done. User can now run the full IAP flow with this email.");
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
