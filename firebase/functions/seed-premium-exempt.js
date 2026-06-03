// One-off seed: grants premium-exempt status to a hand-picked list of
// MomRise testers via two parallel mechanisms:
//
//   1. Adds each lowercased email as a doc id in the `premium_exempt`
//      collection. Picked up by the next app build's isUserPremiumExempt()
//      check (currently in lib/custom_code/actions/stripe_service.dart).
//
//   2. Looks up each email in Firebase Auth and, when found, flips the
//      corresponding users/{uid} doc's subscription_status to "active"
//      with subscription_source = "exempt". This is what unlocks premium
//      in the *currently deployed* build (which doesn't yet know about
//      the exempt collection — pre-rebuild fallback).
//
// Idempotent: re-running just re-writes the same fields.
//
// Usage:
//   node seed-premium-exempt.js path/to/service-account.json

const admin = require("firebase-admin");
const path = require("path");

const KEY_PATH = process.argv[2];
if (!KEY_PATH) {
  console.error("Usage: node seed-premium-exempt.js <service-account.json>");
  process.exit(2);
}

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(KEY_PATH))),
});
const db = admin.firestore();
const auth = admin.auth();

const EMAILS = [
  "ashanator92@gmail.com",
  "audreyrsamuelson@gmail.com",
  // collinjmaddox@gmail.com removed 2026-06-02 — running full IAP flow E2E
  // with the real Apple ID. Add back later if needed.
  "dls4christ17@gmail.com",
  "nikkizmuller@gmail.com",
  "caranw12@gmail.com",
  "haley.hostetter@gmail.com",
  "karilynne87@yahoo.com",
  "jessrobertss@icloud.com",
  "h.medlin03@gmail.com",
  "jennifer.hostetter@gmail.com",
  "marianne_vigor_34@yahoo.com",
  "vdv95@hotmail.com",
  "angelinamdriver6819@gmail.com",
  "acb1604@yahoo.com",
];

async function main() {
  let exemptAdded = 0;
  let usersFlipped = 0;
  let usersNotFound = 0;

  for (const raw of EMAILS) {
    const email = raw.trim().toLowerCase();

    // (1) Seed the exempt collection — kicks in after next app build.
    await db.collection("premium_exempt").doc(email).set({
      added_at: admin.firestore.FieldValue.serverTimestamp(),
      added_by: "launch-seed",
      source_email: raw,
    });
    exemptAdded++;

    // (2) If the user already has a Firebase Auth account, flip their
    // subscription_status so they get premium in the current build too.
    let user;
    try {
      user = await auth.getUserByEmail(email);
    } catch (e) {
      if (e.code === "auth/user-not-found") {
        console.log(`  · ${email}  exempt added (no Auth user yet — will pick up exemption when they sign in to the new build)`);
        usersNotFound++;
        continue;
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
    console.log(`  ✓ ${email}  exempt added + users/${user.uid} flipped to active`);
    usersFlipped++;
  }

  console.log("");
  console.log("Done.");
  console.log(`  ${exemptAdded} exempt docs written`);
  console.log(`  ${usersFlipped} existing Auth users flipped to subscription_status=active`);
  console.log(`  ${usersNotFound} emails had no Auth user yet (exempt doc still saved)`);
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
