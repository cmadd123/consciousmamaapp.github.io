# MomRise Bug Fixes - Testing Guide

**APK Location:** `build\app\outputs\flutter-apk\app-debug.apk`

**Build Date:** March 24, 2026

**Version:** Contains all 10 bug fixes from today's session

---

## Installation Instructions

1. **Transfer APK to Android device:**
   - Connect device via USB and copy `app-debug.apk` to device
   - OR email the APK to yourself and download on device
   - OR use ADB: `adb install build\app\outputs\flutter-apk\app-debug.apk`

2. **Enable installation from unknown sources** (if needed)

3. **Install the APK** by tapping on it

4. **Login** with your existing account

---

## Issue #1: Meal Template Auto-Creation ✅

**What was fixed:** Meals were auto-creating unnamed templates when saved

**How to test:**
1. Go to **Meal Planner** (navbar)
2. Tap any day/meal slot
3. Select an entree (e.g., "Chicken Pasta")
4. Add a side dish (e.g., "Green Beans")
5. Add a drink (e.g., "Water")
6. Tap **Save** button
7. Go to **Saved Days** tab
8. **PASS:** No new unnamed template should appear
9. **FAIL:** If you see a new template with no name, the fix didn't work

**Why this matters:** Prevented clutter in the Saved Days section

---

## Issue #2: iOS Sharing ⚠️ (Device Testing Required)

**Status:** BLOCKED - Needs physical iOS device

**What was investigated:** Share extension code is correct but requires device testing

**Cannot test on Android emulator**

**For iOS device testing:**
1. Open Pinterest on iPhone
2. Find a recipe pin
3. Tap Share → **MomRise** (should appear in share sheet)
4. **PASS:** MomRise opens and imports recipe
5. **FAIL:** MomRise doesn't appear in share sheet OR recipe doesn't import

---

## Issue #3: Templates → Saved Days Rename ✅

**What was fixed:** All UI text changed from "Templates" to "Saved Days"

**How to test:**
1. Go to **Meal Planner**
2. Look for tabs at top of page
3. **PASS:** You see "My Recipes", "Saved Days", "Discover" tabs
4. **FAIL:** You still see "Templates" anywhere

**More places to check:**
- Meal composer screen (when building a meal, look for "Save Saved Day" button)
- Long-press on a saved day → menu should say "Edit Saved Day", "Rename Saved Day", "Delete Saved Day"
- Success messages after saving should say "Saved Day renamed!" not "Template renamed!"

---

## Issue #4: Deep Link Navigation After Inactivity ✅

**What was fixed:** App now navigates to recipe import after being backgrounded

**How to test:**
1. Open **MomRise** app
2. Press **Home button** (minimize app, don't close it)
3. Open **Pinterest** app
4. Find a recipe pin and tap **Share → MomRise**
5. **PASS:** MomRise opens directly to recipe import screen with the recipe loading
6. **FAIL:** MomRise opens to home page, recipe doesn't import

**Key difference:** There's now an 800ms delay to ensure navigation stack is ready

---

## Issue #5: Multiple Recipe Imports ✅

**What was fixed:** Only first recipe was importing when sharing multiple in a row

**How to test:**
1. Open **Pinterest**
2. Find a recipe pin and share to **MomRise** → Wait for import to complete
3. Go **back to Pinterest** (don't close MomRise)
4. Find a **different** recipe pin and share to **MomRise**
5. **PASS:** Second recipe imports and replaces first recipe in the import screen
6. **FAIL:** Second recipe doesn't import, still showing first recipe

**Repeat 3-4 more times** with different recipes to ensure all imports work

---

## Issue #6: Import Recipe Page Refresh ✅

**What was fixed:** Stale data from previous recipe was mixing with new recipe

**How to test:**
1. Share a recipe from **Pinterest** (e.g., "Chocolate Cake")
2. Note the recipe name and ingredients showing
3. Share a **completely different** recipe (e.g., "Grilled Chicken")
4. **PASS:** All fields clear and show only the new recipe data
5. **FAIL:** Some old data (name, ingredients, etc.) still visible mixed with new data

**This works together with Issue #5** - test them both at the same time

---

## Issue #7: Meal Type Tag Auto-Detection ✅

**What was fixed:** Recipes now auto-detect categories (Breakfast/Lunch/Dinner/etc.)

**How to test:**
1. Share a **breakfast recipe** from Pinterest (e.g., "Pancakes" or "Scrambled Eggs")
2. Wait for recipe to import
3. Scroll down to "What kind of recipe is this?" section
4. **PASS:** "Breakfast" chip should be auto-selected (highlighted)
5. Repeat with other types:
   - Lunch recipe (e.g., "Sandwich") → "Lunch" should auto-select
   - Dinner recipe (e.g., "Lasagna") → "Dinner" should auto-select
   - Dessert (e.g., "Brownies") → "Desserts" should auto-select
6. Save the recipe and check if it appears in filtered views

**Keywords that trigger detection:**
- **Breakfast:** pancake, waffle, eggs, bacon, oatmeal, muffin
- **Lunch:** sandwich, wrap, salad, soup, burger
- **Dinner:** pasta, casserole, chicken breast, steak, curry, roast
- **Side:** fries, mashed potato, rice, green beans
- **Snacks:** dip, appetizer, finger food
- **Desserts:** cake, cookie, brownie, pie, ice cream

**Default:** If no keywords match, defaults to "Dinner"

---

## Issue #8: Backend Tag Verification ✅

**What was fixed:** Cloud Function automatically fixes missing meal tags

**How to test (Advanced):**

**Option 1: Check Firebase Console**
1. Go to Firebase Console → Functions
2. Look for `custom_cloud_functions:verifyMealTags`
3. **PASS:** Function should show as "Active"
4. After importing recipes, check function logs for activity

**Option 2: Test automatic fixing**
1. Import a recipe that has NO keywords (e.g., random product page)
2. Save it without selecting any categories
3. Wait 5 seconds
4. Check Firebase Firestore for that meal document
5. **PASS:** `mealTyp` field should automatically be set to "Dinner"

**This is a safety net** - if frontend auto-detection fails, backend fixes it

---

## Issue #9: Navbar Navigation Reliability ✅

**What was fixed:** Home button sometimes didn't respond from calendar

**How to test:**
1. Open **MomRise** app on home page
2. Tap **Calendar** icon in navbar
3. Wait for calendar to load
4. Tap **Home** icon in navbar
5. **PASS:** App navigates back to home page reliably
6. **Repeat 10 times rapidly** (tap Calendar → Home → Calendar → Home)
7. **PASS:** Every tap should work, no unresponsive buttons

**Also test:**
- From calendar → Meals → Home → Calendar (cycle through all tabs)
- Rapid taps (tap Home button 5 times quickly) → Should only navigate once
- Long press on navbar icons → Should still navigate properly

**Key difference:** 50ms delay prevents double-tap issues and ensures context is ready

---

## Issue #10: Keyboard Covering Text Input ✅

**What was fixed:** Keyboard was covering typing box on learning path creation

**How to test:**
1. Go to **Home** page
2. Scroll down to **Learning Paths** card
3. Tap **"+"** or **"Create Learning Path"**
4. Bottom sheet appears with steps
5. On Step 1: "What's the challenge?"
6. **Tap on the text input box** (where it says "Example: My child is struggling...")
7. **PASS:** Keyboard appears AND text input box shifts up above keyboard (you can see what you type)
8. **FAIL:** Keyboard covers the text input box, can't see what you're typing

**Type a long challenge:**
```
My 4-year-old is struggling with counting numbers from 1 to 20 and
often skips numbers or gets confused after 10.
```

**PASS:** You should see all the text you're typing above the keyboard

---

## Additional Verification

### Check All Commits Were Applied

In the app, you should see:
- ✅ No auto-created templates when saving meals
- ✅ All "Templates" text changed to "Saved Days"
- ✅ Navigation works reliably from any page
- ✅ Multiple recipe imports work in succession
- ✅ Recipe categories auto-detect from recipe names
- ✅ Keyboard doesn't cover text inputs in bottom sheets

### Firebase Cloud Function Check

**For advanced users:**
1. Go to [Firebase Console](https://console.firebase.google.com/project/parenting-plus-7szrif/functions)
2. Find `custom_cloud_functions:verifyMealTags`
3. Click on it to see logs
4. After importing recipes, you should see logs like:
   - "Meal abc123 already has mealTyp: Breakfast,Lunch"
   - OR "Auto-detected categories for meal xyz789: Dinner"

---

## Known Limitations

1. **Issue #2 (iOS Sharing):** Requires physical iOS device testing - cannot test on emulator
2. **Backend tag verification:** May take 1-2 seconds to process after meal creation
3. **Category detection:** Only works for recipes with recognizable keywords in the name

---

## Reporting Issues

If any test fails:

1. **Note which issue number failed**
2. **Take screenshots** of the failure
3. **Describe exact steps** to reproduce
4. **Check device/OS version** (Android version, iOS version)
5. **Check if error appears in app logs** (if you have access)

---

## Build Information

- **Build Type:** Debug APK
- **Flutter Version:** Current stable
- **Target SDK:** Android (iOS requires separate build)
- **Commits Included:**
  - `ebee373` - Fix meal template auto-creation
  - `42ba952` - Rename Templates to Saved Days
  - `fa7996a` - Fix deep link navigation
  - `8739f60` - Fix multiple recipe imports
  - `8c16bf6` - Fix import page refresh
  - `3db96e0` - Auto-detect meal type tags
  - `dd395b6` - Backend tag verification
  - `d92b800` - Navbar navigation fix
  - `c8e86fe` - Keyboard overlap fix
  - `375f59b` - Compilation fixes

---

## Success Criteria

**All 10 issues should be resolved:**
- [x] Issue #1: No auto-templates ✅
- [x] Issue #2: iOS sharing (needs device) ⚠️
- [x] Issue #3: Saved Days rename ✅
- [x] Issue #4: Deep link after inactivity ✅
- [x] Issue #5: Multiple imports ✅
- [x] Issue #6: Page refresh ✅
- [x] Issue #7: Tag auto-detection ✅
- [x] Issue #8: Backend verification ✅
- [x] Issue #9: Navbar reliability ✅
- [x] Issue #10: Keyboard overlap ✅

**9/10 testable on Android** (iOS sharing needs iOS device)
