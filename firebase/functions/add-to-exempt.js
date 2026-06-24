// One-off: grants premium-exempt status to a single email. Mirror of
// remove-from-exempt.js. Used when you want to add a tester or family
// member to the exempt list without re-running the bulk seed.
//
// What it does:
//   1. Writes a `premium_exempt/{email}` doc so the next app build's
//      isUserPremiumExempt() check returns true.
//   2. If the user already has a Firebase Auth account, flips their
//      users/{uid} doc to subscription_status=active with
//      subscription_source=exempt so the currently-deployed build
//      unlocks premium for them on next sign-in. If no Auth account
//      exists yet, the exempt doc still gets written and kicks in when
//      they eventually sign up.
//
// Idempotent: re-running on an already-exempt account just re-writes
// the same fields. Safe.
//
// Usage:
//   node add-to-exempt.js <service-account.json> <email>

const admin = require("firebase-admin");
const path = require("path");

const KEY_PATH = process.argv[2];
const EMAIL_RAW = process.argv[3];

if (!KEY_PATH || !EMAIL_RAW) {
  console.error("Usage: node add-to-exempt.js <service-account.json> <email>");
  process.exit(2);
}

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(KEY_PATH))),
});
const db = admin.firestore();
const auth = admin.auth();

async function main() {
  const email = EMAIL_RAW.trim().toLowerCase();
  console.log(`Adding premium-exempt for: ${email}`);

  // 1. Seed the exempt collection.
  await db.collection("premium_exempt").doc(email).set({
    added_at: admin.firestore.FieldValue.serverTimestamp(),
    added_by: "add-to-exempt-script",
    source_email: EMAIL_RAW,
  });
  console.log(`  ✓ Wrote premium_exempt/${email}`);

  // 2. If an Auth user exists, flip their subscription state.
  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === "auth/user-not-found") {
      console.log(`  · No Auth user yet — exemption will activate on first sign-in.`);
      process.exit(0);
    }
    throw e;
  }

  await db.collection("users").doc(user.uid).set(
    {
      subscription_status: "active",
      subscription_source: "exempt",
      subscription_plan: "lifetime_exempt",
      subscription_updated_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`  ✓ Flipped users/${user.uid} to subscription_status=active (source=exempt)`);

  console.log("");
  console.log("Done.");
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
