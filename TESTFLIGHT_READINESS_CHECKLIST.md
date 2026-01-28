# TestFlight Readiness Checklist - MomRise

## 🚀 Build Status

**Build Triggered:** 2026-01-27
**Status:** Building in Codemagic (check https://codemagic.io/apps)
**Expected Time:** 10-15 minutes for build, then 5-10 minutes for Apple processing

---

## ✅ Completed Setup

- [x] App created in App Store Connect (com.momrise.app)
- [x] Bundle ID registered
- [x] Custom domain configured (momrise.app)
- [x] Codemagic CI/CD configured
- [x] iOS Distribution Certificate generated
- [x] API credentials configured
- [x] Android package name updated
- [x] Share links updated to momrise.app/s

---

## ⚠️ CRITICAL: Must Do Before Sharing Feature Works

### iOS Associated Domains (Required for Deep Linking)

**This MUST be added in Xcode** or iOS deep linking won't work:

1. Open `mome_coach/ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Click **"+ Capability"** → **"Associated Domains"**
4. Add these domains:
   - `applinks:momrise.app`
   - `applinks:cmadd123.github.io`
5. Save, commit, and push to trigger new build

**Without this, share links will open in Safari instead of the app on iOS!**

---

## 🧪 Testing Plan with Testers

### Phase 1: Basic Functionality (Day 1-2)
- [ ] App installs from TestFlight
- [ ] Account creation works
- [ ] Add child profile
- [ ] Create learning path (tests OpenAI API)
- [ ] Browse activities
- [ ] Use calendar

### Phase 2: Sharing Feature (Day 3-5)
- [ ] Share an activity → Verify link is momrise.app/s/xxxxxxxx
- [ ] Tap link on Android → Should open app (not browser)
- [ ] Tap link on iOS → Should open app (not browser) **[REQUIRES Associated Domains]**
- [ ] Import shared content
- [ ] Share learning path
- [ ] Share meal plan

### Phase 3: Real-World Usage (Day 6-14)
- [ ] Daily usage patterns
- [ ] Performance issues?
- [ ] Crash reports?
- [ ] Feature requests
- [ ] UI/UX feedback

---

## 🔒 Firebase App Check (Do After TestFlight Works)

**Current Status:** Not enabled (optional but recommended)

**When to enable:**
1. After testers confirm app works
2. Before public launch
3. Protects OpenAI API from abuse

**How to enable:**
See FIREBASE_APP_CHECK_SETUP.md

**Start with "Unenforced" mode** to log violations without blocking requests.

---

## 📸 App Store Screenshots (After Tester Feedback)

**You're right** - wait for tester feedback before finalizing screenshots!

**Screens needed (5 minimum):**
1. Home screen with child card
2. Learning path creation
3. Activity suggestions
4. Milestone tracking
5. Learning path details with tasks

**Sizes needed:**
- 6.7" (iPhone 15 Pro Max): 1290 x 2796 px
- iPad Pro 12.9" (optional): 2048 x 2732 px

---

## 📋 Post-Build Checklist

### Immediately After Build Succeeds

1. [ ] Check Codemagic for "Build successful" status
2. [ ] Go to App Store Connect → My Apps → MomRise → TestFlight
3. [ ] Wait for build to finish "Processing" (5-10 min)
4. [ ] Add internal testers:
   - Click "Internal Testing" → Default group
   - Add tester emails
   - They'll receive TestFlight invite

### Before Sending to Testers

5. [ ] **Add Associated Domains in Xcode** (critical for sharing!)
6. [ ] Push update to trigger new build
7. [ ] Wait for new build to process
8. [ ] Test deep linking yourself first

### Tester Instructions to Send

```
Hi! You've been invited to test MomRise on TestFlight.

1. Install TestFlight app from App Store
2. Check your email for the invite
3. Tap "View in TestFlight" → Install

Please test:
- Creating a learning path for your child
- Sharing an activity (tap share button, copy link)
- Tapping a share link someone sends you
- General app usage

Report any bugs or feedback!
```

---

## 🐛 Known Issues to Watch For

### From CLAUDE.md Pending Work:

1. **OpenAI API errors** - Learning path creation may fail
2. **Add Child page** - Gender dropdown styling issue
3. **Cleanup difficulty** - Color issue (using green incorrectly)
4. **Welcome page** - Scrolling problems
5. **Login flow** - May loop back to onboarding

### High Priority:
6. **Data duplication** - Fixed in v1.2.323 but watch for it
7. **Daily rate limits** - AI safety controls in place

---

## 📊 Success Metrics

**TestFlight is successful if:**
- ✅ 80%+ of testers can complete basic tasks
- ✅ No critical crashes
- ✅ Share links work on both iOS and Android
- ✅ Positive feedback on core features
- ✅ Testers want to keep using it

**Red flags:**
- ❌ Testers can't create learning paths (API issues)
- ❌ App crashes frequently
- ❌ Share links don't open in app
- ❌ Too many bugs reported

---

## 🚦 Next Steps After TestFlight

### If TestFlight Goes Well:
1. Fix critical bugs from feedback
2. Update screenshots based on tester suggestions
3. Write/refine App Store description
4. Enable Firebase App Check (Enforced mode)
5. Submit for App Review

### If Issues Found:
1. Fix critical bugs
2. Push update → new build
3. Re-test with testers
4. Iterate until stable

---

## 📞 Support During Testing

**How to check build status:**
- Codemagic: https://codemagic.io/apps
- App Store Connect: https://appstoreconnect.apple.com

**How to check Firebase:**
- Console: https://console.firebase.google.com/project/parenting-plus-7szrif
- Check Cloud Functions logs for errors
- Monitor Firestore usage

**Quick fixes:**
- Build failed? Check Codemagic logs
- Upload failed? Check API credentials
- App crashes? Check Firebase Crashlytics

---

## 🎯 Current Focus

**Right now:**
1. Wait for Codemagic build to complete
2. Once processed, add Associated Domains in Xcode
3. Trigger new build
4. Add testers to TestFlight
5. Begin testing phase

**You're 90% there!** Just need to:
- Add Associated Domains (5 minutes in Xcode)
- Wait for builds to complete
- Start testing with your target audience tester
