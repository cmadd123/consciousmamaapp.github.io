// MomRise — delete a family's personal data when their account is deleted.
//
// privacy.html promises that deleting your account deletes your associated
// data. onUserDeleted used to remove only users/{uid}. This module removes
// every personal collection, using the ownership fields that firestore.rules
// already relies on.
//
// Deliberately NOT deleted here:
//  - Curated library recipes (meal docs with is_curated == true). They power
//    the public recipe catalog and may be owned by an admin account.
//  - Creator-program records (creators, creator_content, creator_earnings,
//    payouts …): financial/tax records with their own deletion flow
//    (requestCreatorAccountDeletion).
//  - app_content docs that belong to a creator (creator_ref set).
//  - reminders: they hold only a push token and expire once sent.
//  - Cloud Storage files (e.g. uploaded photos) — see TODO at the bottom.

const { getFirestore } = require('firebase-admin/firestore');

// [collection, owner field]. Owner fields are DocumentReferences to users/{uid}.
const OWNED_COLLECTIONS = [
  ['meal_plan', 'user_ref'],
  ['meal', 'user_ref'],
  ['meal_combo', 'user_ref'],
  ['favourit_meal', 'user_ref'],
  ['learning_path', 'user_ref'],
  ['learning_path_tasks', 'user_ref'],
  ['skill_paths', 'user_ref'],
  ['event_and_task', 'user_ref'],
  ['todos', 'user_ref'],
  ['routines', 'user_ref'],
  ['planned_activities', 'user_ref'],
  ['user_activities', 'user_ref'],
  ['fav_activity', 'user_ref'],
  ['app_content', 'user_ref'],
  ['shared_content', 'shared_by_user'],
];

// Per-collection guard: return false to KEEP a doc.
const KEEP_IF = {
  meal: (d) => d.is_curated !== true,
  app_content: (d) => !d.creator_ref,
};

const PAGE = 300;

async function deleteQuery(db, query, shouldDelete) {
  let deleted = 0;
  let last = null;
  // Page by document id so docs we deliberately keep don't cause a loop.
  for (;;) {
    let q = query.orderBy('__name__').limit(PAGE);
    if (last) q = q.startAfter(last);
    const snap = await q.get();
    if (snap.empty) break;
    const batch = db.batch();
    let n = 0;
    for (const doc of snap.docs) {
      if (!shouldDelete || shouldDelete(doc.data())) { batch.delete(doc.ref); n++; }
    }
    if (n) await batch.commit();
    deleted += n;
    last = snap.docs[snap.docs.length - 1];
    if (snap.size < PAGE) break;
  }
  return deleted;
}

/**
 * Delete all personal data for uid. Each collection is attempted
 * independently so one failure never blocks the rest. Returns a summary
 * { counts: {collection: n}, errors: {collection: message} }.
 */
async function deleteUserData(uid) {
  const db = getFirestore();
  const userRef = db.collection('users').doc(uid);
  const counts = {};
  const errors = {};

  // Children first: their milestone records reference the child, not the user.
  try {
    const kids = await db.collection('childern').where('userRef', '==', userRef).get();
    let milestones = 0;
    for (const kid of kids.docs) {
      milestones += await deleteQuery(
        db, db.collection('children_accomlished_milestones').where('child', '==', kid.ref));
    }
    counts.children_accomlished_milestones = milestones;
    counts.childern = await deleteQuery(db, db.collection('childern').where('userRef', '==', userRef));
  } catch (e) {
    errors.childern = String(e && e.message || e);
  }

  for (const [name, field] of OWNED_COLLECTIONS) {
    try {
      counts[name] = await deleteQuery(
        db, db.collection(name).where(field, '==', userRef), KEEP_IF[name]);
    } catch (e) {
      errors[name] = String(e && e.message || e);
    }
  }

  // TODO(Collin): uploaded files in Cloud Storage (recipe photos, avatars,
  // cookbook scans) are not removed yet. Add a prefix delete here once the
  // storage path convention per user is confirmed.

  return { counts, errors };
}

module.exports = { deleteUserData, OWNED_COLLECTIONS };
