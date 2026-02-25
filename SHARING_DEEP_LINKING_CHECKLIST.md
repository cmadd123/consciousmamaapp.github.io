# MomRise Sharing & Deep Linking Checklist

## ✅ Completed Setup

### Domain & DNS
- [x] Domain registered: momrise.app
- [x] DNS configured on Hostinger (A records, CNAME)
- [x] GitHub Pages configured with custom domain
- [x] HTTPS enabled (via Let's Encrypt)

### Android App Links
- [x] AndroidManifest.xml updated with momrise.app intent filters
- [x] assetlinks.json uploaded to website/.well-known/
- [x] Package name updated to com.momrise.app
- [x] SHA-256 fingerprints in assetlinks.json (from Android keystore)

### iOS Universal Links
- [ ] **TODO: Add Associated Domains to Xcode**
  - Need to add in Xcode: applinks:momrise.app
  - Location: Runner target → Signing & Capabilities → Associated Domains
  - This allows iOS to open momrise.app/s/* links in the app

### Share URL System
- [x] Base URL: https://momrise.app/s/{8-char-code}
- [x] sharing_service.dart updated with new domain
- [x] Website landing page at s/index.html
- [x] 404.html redirects share URLs to landing page
- [x] deep_link_handler.dart handles incoming links

## 🧪 Testing Checklist (After TestFlight Build)

### Test Share Links (Do This First!)

1. **Create a share link in the app**
   - Share an activity, meal plan, or learning path
   - Copy the link (should be momrise.app/s/xxxxxxxx)

2. **Test Android Deep Linking**
   - Send link via text message to Android device
   - Tap link → Should open app (not browser)
   - Verify content imports correctly

3. **Test iOS Universal Links**
   - Send link via text message to iPhone
   - Tap link → Should open app (not browser)
   - Verify content imports correctly

4. **Test Fallback (Browser)**
   - Open link in Safari/Chrome
   - Should see landing page with "Open in App" button
   - Button should deep link to app

### Common Issues & Fixes

**Link opens browser instead of app:**
- Android: Verify assetlinks.json is accessible at https://momrise.app/.well-known/assetlinks.json
- iOS: Add Associated Domains in Xcode (see TODO above)
- Both: Try uninstalling and reinstalling the app

**Import fails after deep link:**
- Check Firebase logs for errors
- Verify share code exists in Firestore (shared_content collection)
- Check deep_link_handler.dart for errors

## ⚠️ Critical TODO Before Launch

### Release Checklist — assetlinks.json SHA Fingerprint

**Before publishing a release build**, update `.well-known/assetlinks.json` with the **release keystore SHA-256 fingerprint** (the current fingerprint is from the debug keystore).

To get the release SHA-256:
```bash
keytool -list -v -keystore <your-release-keystore>.jks -alias <alias>
```
Copy the `SHA256:` value and replace the fingerprint in `.well-known/assetlinks.json`. Without this, Android App Links will NOT work on release builds — share links will open the browser instead of the app.

### iOS Associated Domains (Required for Universal Links)

**You MUST do this in Xcode before iOS deep linking will work:**

1. Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj!)
2. Select **Runner** target
3. Click **"Signing & Capabilities"** tab
4. Click **"+ Capability"** button
5. Add **"Associated Domains"**
6. Click **"+"** under Domains
7. Add: `applinks:momrise.app`
8. Add: `applinks:cmadd123.github.io` (legacy GitHub Pages)
9. Save and commit changes

**File that will be modified:**
- `ios/Runner/Runner.entitlements`

This tells iOS that your app should handle momrise.app links.

## 🔗 Share Link Types Supported

All of these work with the same momrise.app/s/{code} format:

1. **Single Activity** - Share one activity to another parent
2. **Activity Plan** - Share a week of activities
3. **Meal Plan** - Share a weekly meal plan
4. **Single Day Meals** - Share one day's meals
5. **Single Meal** - Share a specific meal
6. **Single Recipe** - Share a recipe
7. **Recipe Combo** - Share a recipe combination
8. **Learning Path** - Share an entire learning path

## 📊 Monitoring

After launch, monitor:
- Firebase Console → Firestore → shared_content collection (usage stats)
- Check for failed imports (error logs)
- User feedback on sharing feature

## 🚀 Post-TestFlight Actions

After testers confirm sharing works:

1. Update CLAUDE.md with tester feedback
2. Fix any reported issues
3. Enable Firebase App Check (Enforced mode)
4. Monitor share link usage in Firestore
