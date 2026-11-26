# Meal-acceptance feedback ("How did it go?")

The data-capture foundation for the meal-acceptance dataset (MOMRISE_TRAFFIC_BRIEF.md, moat #1). After a planned meal passes, parents can tap one of 😋 Loved it / 👍 Ate some / 🙅 Refused per child, and optionally answer "Make again?". A weekly job turns the ratings into anonymized aggregates, such as "dinners 3-year-olds accept, from N families".

## What it captures
One `meal_feedback` doc per child per planned meal. If the family has no children, there is one family-level doc instead. Every tap saves straight away; there is no submit step.

## Where the UI lives (`lib/v2/meal_feedback/`)
| Where | When it shows |
|---|---|
| **Home** (`MealFeedbackHomeCard`, under Today's Meals in `home_hybrid_widget.dart`) | At most **one** meal: the most recent past, recipe-backed, unrated meal from today or the previous 2 days. Hidden for the rest of the day after "Not now" or ✕, and that meal is never asked about on Home again. After 3 dismissals in a row it snoozes for 14 days. "Don't ask" turns it off (Undo is offered). It renders nothing while loading or on error. |
| **Week plan** (`MealFeedbackInlineChip`, inside each planned meal card in `create_meal_plan_widget.dart`) | Past, recipe-backed meals from the last 14 days only. Unrated meals from the last 7 days show a "How did it go? 😋 👍 🙅" pill, and rated meals show "Rated 😋 👍 🔁". Tapping either opens the bottom sheet (`showMealFeedbackSheet`), which also has "Remove my ratings for this meal" and the on/off switch. |
| **Settings** (Notification settings → "Meal Check-ins") | An on/off switch. It is in-app, so it works without OS notification permission. |

- **What counts as "past":** the plan date plus the meal's cut-off time (Breakfast 10:00, Lunch 14:00, Snacks 16:00, Dinner 19:00, local time).
- **What can't be rated:** custom meals ("Eating out") and empty slots.
- **Which children are asked about:** meal plans don't assign children, so every child in the family is listed, except children born after the plan date.
- **Where the preferences live:** in SharedPreferences on the device (`meal_feedback_*` keys), not in Firestore.

## Data model: `meal_feedback/{mealPlanId}_{childId|family}`
| field | type | notes |
|---|---|---|
| user_ref | ref users/{uid} | owner (rules enforce it is the caller) |
| child_ref | ref childern/{id}? | absent for a family-level rating |
| child_age_months | int? | age on the plan date. **The birthdate is never stored.** |
| meal_plan_ref | ref meal_plan/{id} | the planned meal |
| recipe_ref / meal_combo_ref | ref? | entrée recipe / combo |
| recipe_name | string ≤200 | entrée name, falling back to the combo name |
| meal_type | Breakfast/Lunch/Dinner/Snacks | |
| tags | string[] ≤20 | meal_typ categories, recipe_type, curated/imported/combo |
| rating | `loved` \| `ate_some` \| `refused` | |
| make_again | bool? | absent until answered |
| plan_date | timestamp | |
| created_at / updated_at | server timestamps | |

- **Record class:** `lib/backend/schema/meal_feedback_record.dart`, with query helpers in `backend.dart`.
- **Rules:** a separate `match /meal_feedback` block in `firestore.rules`, placed after `meal_plan`. Only the owner can read, create, update or delete. The rules allow only the listed keys and check field types and the rating enum. `created_at` must equal `request.time` on create and can't change on update.
- **Stats collections:** `meal_feedback_stats` and `meal_feedback_stats_meta` deny all client access.
- **Indexes:** none needed. The queries are `user_ref ==` combined with `meal_plan_ref ==`/`in`, which Firestore serves by merging single-field indexes. The Home query also uses `user_ref + date`, which is covered by the existing `meal_plan` composite index.
- **Analytics:** each rating logs `meal_feedback_submitted` with `rating`, `meal_type`, `per_child` (0/1) and `make_again` (0/1). No PII is sent.

## Aggregation: `aggregateMealFeedback` (`functions/meal_feedback_aggregate.js`)
- **Schedule and method:** it runs every Monday at 04:00 America/Chicago through the admin SDK. Each run rebuilds everything from all of `meal_feedback`.
- **Cell key:** a cell is **normalized recipe name × age band × meal type**. Recipes are per-user docs, so the name is the only key that is shared across families.
- **Age bands:** `6_11m`, `12_23m`, `2y`, `3y`, `4_5y`, `6y_plus`. Two extra bands catch the rest: `under_6m`, and `unknown` (family-level ratings or no birthdate).
- **Per cell it writes:**
  - counts per rating and `total_ratings`
  - `loved_rate`, `acceptance_rate` (loved + ate some) and `refused_rate`
  - `make_again_rate` and the number of `make_again_responses`
  - `distinct_families`
- **K-anonymity floor:** a cell is published only when `distinct_families >= K_ANONYMITY_FLOOR` (**20**, a constant). The display name is the most common spelling only if at least 20 families use it; otherwise it is the normalized key.
- **What the output never contains:** user ids, child ids, refs or dates.
- **Run summary:** each run writes totals and suppressed-cell counts to `meal_feedback_stats_meta/latest`.
- **Stale cells are deleted.** When deletions push a cell below the floor, it disappears on the next run.
- **Account deletion:** `onUserDeleted` now also deletes the user's `meal_feedback` docs.

## Deploy
**Never run a bare `firebase deploy`.** `firebase.json` also deploys `remoteconfig.template.json`, which would overwrite live Remote Config.
```bash
firebase deploy --only functions:aggregateMealFeedback,functions:onUserDeleted
firebase deploy --only firestore:rules   # deploys the WHOLE firestore.rules file
```
- **Merge the rules first.** `firestore:rules` deploys the entire file, so merge/rebase this branch with whichever branch is rewriting the `users/{uid}` and `premium_exempt` blocks, then deploy from the merged file. Deploying either branch alone would revert the other's rules.
- **Order matters.** Deploy the rules before the app build ships. Without them, every `meal_feedback` read/write is denied. The UI degrades by showing nothing, but no data is collected.
- **To run the job once by hand:** Cloud Scheduler → `firebase-schedule-aggregateMealFeedback-*` → Force run.

## Testing on a device
1. Deploy the rules. Plan a recipe-backed **dinner for yesterday**, or a breakfast for today (past 10:00).
2. **Home:** the card "How did last night's dinner go?" appears under Today's Meals.
   - Tap a rating for each child. The card shows "Thanks — noted!" and collapses after about 6 s.
   - Check Firestore for `meal_feedback/{planId}_{childId}`: the age is in months and there is no birthdate.
3. **Dismissals:** plan another past meal, tap "Not now", and reopen Home. The card stays hidden for the rest of today.
4. **Week plan:** the past meal card shows "Rated 😋". Tap it, change a rating, set "Make again?", then "Remove my ratings". Watch the doc update and then disappear.
5. **Turning it off:** "Don't ask" hides the Home card and the unrated pills. Notification settings → Meal Check-ins turns them back on.
6. **Aggregation:** force-run the function. With fewer than 20 families, `meal_feedback_stats` stays empty and `meal_feedback_stats_meta/latest` shows the suppressed count.
   - The pure logic can be tested in Node through `require('./meal_feedback_aggregate')._internal.buildAggregates(docs)`.
7. **Account deletion:** delete a test account. Its `meal_feedback` docs disappear (check the function logs).
