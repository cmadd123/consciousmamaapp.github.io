// Firestore rules tests for the entitlement lockdown (users/{uid}) and the
// premium_exempt read restrictions.
//
// Run (needs the Firebase CLI + Java for the emulator):
//   cd rules-tests && npm install
//   npm run test:emulator
// or, with an emulator already running on 127.0.0.1:8080:
//   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm test

const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs,
  serverTimestamp, deleteField, Timestamp,
} = require('firebase/firestore');

let testEnv;

const ALICE = 'alice';

function aliceDb() {
  return testEnv.authenticatedContext(ALICE, { email: 'alice@example.com' }).firestore();
}

async function seedUser(data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), `users/${ALICE}`), data);
  });
}

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080').split(':');
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-momrise',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host,
      port: Number(port),
    },
  });
});

after(async () => { await testEnv.cleanup(); });
beforeEach(async () => { await testEnv.clearFirestore(); });

describe('users/{uid} — create', () => {
  it('allows a normal profile create (maybeCreateUser)', async () => {
    await assertSucceeds(setDoc(doc(aliceDb(), `users/${ALICE}`), {
      email: 'alice@example.com', uid: ALICE, created_time: Timestamp.now(),
    }));
  });

  it('allows create with free_trial_start = serverTimestamp()', async () => {
    await assertSucceeds(setDoc(doc(aliceDb(), `users/${ALICE}`), {
      uid: ALICE, free_trial_start: serverTimestamp(),
    }));
  });

  it('denies create with a back-dated free_trial_start', async () => {
    await assertFails(setDoc(doc(aliceDb(), `users/${ALICE}`), {
      uid: ALICE, free_trial_start: Timestamp.fromDate(new Date('2030-01-01')),
    }));
  });

  it('denies create with subscription_status', async () => {
    await assertFails(setDoc(doc(aliceDb(), `users/${ALICE}`), {
      uid: ALICE, subscription_status: 'active',
    }));
  });

  it('denies creating someone else\'s doc', async () => {
    await assertFails(setDoc(doc(aliceDb(), 'users/bob'), { uid: 'bob' }));
  });
});

describe('users/{uid} — update', () => {
  beforeEach(async () => {
    await seedUser({ uid: ALICE, email: 'alice@example.com', display_name: 'A' });
  });

  it('allows ordinary profile updates', async () => {
    await assertSucceeds(updateDoc(doc(aliceDb(), `users/${ALICE}`), {
      display_name: 'Alice', fcmToken: 'tok', onboarding_completed: true,
    }));
  });

  for (const [field, value] of [
    ['subscription_status', 'active'],
    ['subscription_status', 'trialing'],
    ['subscription_plan', 'annual'],
    ['subscription_source', 'apple_iap'],
    ['subscription_id', 'sub_123'],
    ['stripe_customer_id', 'cus_123'],
    ['is_comped', true],
    ['current_period_end', Timestamp.fromDate(new Date('2099-01-01'))],
    ['google_purchase_token', 'tok'],
    ['apple_transaction_id', '2000000'],
    ['entitlement_verified_at', Timestamp.now()],
  ]) {
    it(`denies client write of ${field}`, async () => {
      await assertFails(updateDoc(doc(aliceDb(), `users/${ALICE}`), { [field]: value }));
    });
  }

  it('denies the old iap_service.dart _markSubscribed merge-set', async () => {
    await assertFails(setDoc(doc(aliceDb(), `users/${ALICE}`), {
      subscription_status: 'active',
      subscription_plan: 'monthly',
      subscription_updated_at: serverTimestamp(),
      free_trial_start: serverTimestamp(),
      subscription_source: 'apple_iap',
    }, { merge: true }));
  });

  it('allows setting free_trial_start once with serverTimestamp (onboarding)', async () => {
    await assertSucceeds(updateDoc(doc(aliceDb(), `users/${ALICE}`), {
      onboarding_completed: true, free_trial_start: serverTimestamp(),
    }));
  });

  it('denies setting free_trial_start to a client-chosen time', async () => {
    await assertFails(updateDoc(doc(aliceDb(), `users/${ALICE}`), {
      free_trial_start: Timestamp.fromDate(new Date('2030-01-01')),
    }));
  });

  it('denies resetting an existing free_trial_start', async () => {
    await seedUser({ uid: ALICE, free_trial_start: Timestamp.fromDate(new Date('2025-01-01')) });
    await assertFails(updateDoc(doc(aliceDb(), `users/${ALICE}`), {
      free_trial_start: serverTimestamp(),
    }));
  });

  it('denies deleting free_trial_start', async () => {
    await seedUser({ uid: ALICE, free_trial_start: Timestamp.fromDate(new Date('2025-01-01')) });
    await assertFails(updateDoc(doc(aliceDb(), `users/${ALICE}`), {
      free_trial_start: deleteField(),
    }));
  });

  it('allows updates on a doc that already has server-written entitlement fields', async () => {
    await seedUser({ uid: ALICE, subscription_status: 'active', stripe_customer_id: 'cus_1' });
    await assertSucceeds(updateDoc(doc(aliceDb(), `users/${ALICE}`), { display_name: 'New' }));
    // Re-writing the same value is not a change and is allowed (FlutterFlow
    // sometimes writes whole maps back).
    await assertSucceeds(setDoc(doc(aliceDb(), `users/${ALICE}`),
      { subscription_status: 'active' }, { merge: true }));
  });

  it('allows setting apple_app_account_token once, not changing it', async () => {
    await assertSucceeds(setDoc(doc(aliceDb(), `users/${ALICE}`),
      { apple_app_account_token: '0f8fad5b-d9cb-469f-a165-70867728950e' }, { merge: true }));
    await assertFails(updateDoc(doc(aliceDb(), `users/${ALICE}`),
      { apple_app_account_token: '7c9e6679-7425-40de-944b-e07fc1f90ae7' }));
  });

  it('denies deleting the users doc from the client', async () => {
    await assertFails(deleteDoc(doc(aliceDb(), `users/${ALICE}`)));
  });

  it('denies reading another user', async () => {
    await assertFails(getDoc(doc(aliceDb(), 'users/bob')));
  });
});

describe('premium_exempt', () => {
  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'premium_exempt/alice@example.com'), { added_at: Timestamp.now() });
      await setDoc(doc(ctx.firestore(), 'premium_exempt/someone@else.com'), { added_at: Timestamp.now() });
      await setDoc(doc(ctx.firestore(), `premium_exempt/${ALICE}`), { added_at: Timestamp.now() });
    });
  });

  it('allows get of own uid doc', async () => {
    await assertSucceeds(getDoc(doc(aliceDb(), `premium_exempt/${ALICE}`)));
  });

  it('allows get of own email doc', async () => {
    await assertSucceeds(getDoc(doc(aliceDb(), 'premium_exempt/alice@example.com')));
  });

  it('denies get of another email doc', async () => {
    await assertFails(getDoc(doc(aliceDb(), 'premium_exempt/someone@else.com')));
  });

  it('denies listing the collection', async () => {
    await assertFails(getDocs(collection(aliceDb(), 'premium_exempt')));
  });

  it('denies client writes', async () => {
    await assertFails(setDoc(doc(aliceDb(), `premium_exempt/${ALICE}`), { x: 1 }));
  });
});

describe('server-only collections', () => {
  for (const col of ['store_purchase_bindings', 'entitlement_audit', 'ai_usage']) {
    it(`denies client read/write on ${col}`, async () => {
      await assertFails(getDoc(doc(aliceDb(), `${col}/${ALICE}`)));
      await assertFails(setDoc(doc(aliceDb(), `${col}/${ALICE}`), { x: 1 }));
    });
  }
});
