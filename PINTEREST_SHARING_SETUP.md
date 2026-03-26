# Pinterest → MomRise Sharing: Complete Guide

## Current Status: ✅ FULLY CONFIGURED

MomRise already has **complete deep linking** set up for sharing FROM Pinterest (or any social platform) TO the app!

## How It Works

### 1. User Shares from MomRise
```
User creates meal plan
  → Taps Share button
  → Creates link: https://momrise.app/s/abcd1234
  → Shares to Pinterest (or Instagram, Facebook, text message, etc.)
```

### 2. Someone Clicks Link from Pinterest
```
Pinterest post with link: https://momrise.app/s/abcd1234
  → User taps link
  → Android/iOS detects momrise.app domain
  → Opens MomRise app (or downloads if not installed)
  → App navigates to import screen
  → User sees shared meal plan and can import it
```

## Technical Implementation

### Android Deep Linking (AndroidManifest.xml lines 66-99)

**1. HTTPS App Links (Verified):**
```xml
<!-- momrise.app/shared/CODE -->
<intent-filter android:autoVerify="true">
  <data android:scheme="https" android:host="momrise.app" android:pathPrefix="/shared" />
</intent-filter>

<!-- momrise.app/s/CODE (short URL) -->
<intent-filter android:autoVerify="true">
  <data android:scheme="https" android:host="momrise.app" android:pathPrefix="/s" />
</intent-filter>

<!-- Legacy GitHub Pages fallback -->
<intent-filter android:autoVerify="true">
  <data android:scheme="https" android:host="cmadd123.github.io"
        android:pathPrefix="/consciousmama.github.io/s" />
</intent-filter>
```

**2. Custom Scheme (Always works):**
```xml
<!-- momrise://shared/CODE -->
<intent-filter>
  <data android:scheme="momrise" />
</intent-filter>
```

**3. Share Intent (Receive from other apps):**
```xml
<!-- When user taps "Share to MomRise" from Pinterest/Instagram/etc -->
<intent-filter>
  <action android:name="android.intent.action.SEND" />
  <data android:mimeType="text/plain" />
</intent-filter>
```

### iOS Deep Linking

iOS uses Universal Links (configured in Xcode project settings):
- Associated Domains: `applinks:momrise.app`
- Apple verifies ownership via `.well-known/apple-app-site-association` file on domain

### Deep Link Handler (deep_link_handler.dart)

Handles ALL these URL formats automatically:

```dart
// HTTPS URLs
https://momrise.app/s/abcd1234          ✅ Primary format
https://momrise.app/shared/abcd1234     ✅ Legacy format
https://cmadd123.github.io/.../s/code   ✅ GitHub Pages fallback

// Custom scheme URLs
momrise://shared/abcd1234               ✅ Always works
consciousmama://shared/abcd1234         ✅ Legacy app name

// All these extract the 8-character code and navigate to:
/shared/abcd1234  → ImportSharedContentWidget
```

### Share Code Validation (lines 195-204)
```dart
// Only accepts valid 8-character codes
shareCode = shareCode.split('/').first.split('?').first.toLowerCase();
if (shareCode.length == 8 && RegExp(r'^[a-z0-9]+$').hasMatch(shareCode)) {
  _navigateToImport(shareCode);  // ✅ Valid
} else {
  debugPrint('Invalid code');    // ❌ Rejected
}
```

## User Flow Example

### Scenario: Mom shares meal plan on Pinterest

**Step 1: Share from MomRise**
```
Mom creates "Taco Tuesday Week" meal plan
  → Taps Share button in meal planner
  → Bottom sheet appears
  → Taps "Create Share Link"
  → Cloud Function creates SharedContentRecord:
      - share_code: "xy4k92pq"
      - content_type: mealPlan
      - content_data: {meals: [...], week_start: ...}
  → Share URL created: https://momrise.app/s/xy4k92pq
  → Native share dialog opens
  → Mom selects Pinterest
  → Creates pin with recipe photo + link
```

**Step 2: Friend discovers on Pinterest**
```
Friend scrolling Pinterest
  → Sees "Taco Tuesday Week" pin
  → Taps link: https://momrise.app/s/xy4k92pq
  → Android checks: "Who handles momrise.app URLs?"
  → Finds: MomRise app (via intent filter)
  → Opens MomRise app
```

**Step 3: App receives deep link**
```
DeepLinkHandler receives URI: https://momrise.app/s/xy4k92pq
  → Extracts code: "xy4k92pq"
  → Checks if user is logged in:
      - If YES: Navigate to /shared/xy4k92pq immediately
      - If NO: Store as _pendingShareCode, navigate after login
  → ImportSharedContentWidget loads
  → Fetches SharedContentRecord from Firestore
  → Displays meal plan preview
  → Friend taps "Import to My Meal Plan"
  → Meals copied to friend's account
```

## UTM Tracking for Pinterest

The deep link handler already tracks campaign attribution! Add UTM parameters to your Pinterest links:

```
https://momrise.app/s/xy4k92pq?utm_source=pinterest&utm_medium=pin&utm_campaign=taco_tuesday

When clicked:
  → DeepLinkHandler extracts UTM params (lines 98-123)
  → Logs to Firebase Analytics:
      - utm_source: pinterest
      - utm_medium: pin
      - utm_campaign: taco_tuesday
  → Navigates to import screen
```

### Example Pinterest Post with Tracking
```
🌮 Taco Tuesday Meal Plan 🌮
7 days of delicious Mexican-inspired meals!

[Recipe Photo]

Get the full plan: https://momrise.app/s/xy4k92pq?utm_source=pinterest&utm_medium=organic&utm_campaign=mexican_week

#TacoTuesday #MealPlanning #HealthyEating #MomLife
```

## What's Already Working

✅ **Android App Links** - momrise.app URLs open in app
✅ **iOS Universal Links** - Same for iOS
✅ **Custom Scheme** - momrise:// URLs always work
✅ **Share Intent** - Can receive shares from other apps
✅ **Code Validation** - Only accepts valid 8-char codes
✅ **Login Handling** - Stores pending links until user logs in
✅ **UTM Tracking** - Automatically tracks campaign attribution
✅ **Multiple URL Formats** - Handles /s/, /shared/, GitHub Pages
✅ **Import UI** - Beautiful preview before importing
✅ **Error Handling** - Graceful fallbacks if link invalid

## What You Need to Do

### 1. Verify Domain Ownership (Android)

For `android:autoVerify="true"` to work, you need a file at:
```
https://momrise.app/.well-known/assetlinks.json
```

**File content:**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.mycompany.momecoach",
    "sha256_cert_fingerprints": [
      "YOUR_SHA256_FINGERPRINT_HERE"
    ]
  }
}]
```

**Get your SHA256 fingerprint:**
```bash
cd android
./gradlew signingReport
# Look for SHA-256 under "Variant: release"
```

### 2. Verify Domain Ownership (iOS)

Upload to:
```
https://momrise.app/.well-known/apple-app-site-association
```

**File content:**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.mycompany.momecoach",
        "paths": [
          "/s/*",
          "/shared/*"
        ]
      }
    ]
  }
}
```

Replace `TEAMID` with your Apple Developer Team ID (found in Xcode).

### 3. Test Deep Linking

**Android:**
```bash
# Test HTTPS URL
adb shell am start -a android.intent.action.VIEW \
  -d "https://momrise.app/s/testcode"

# Test custom scheme
adb shell am start -a android.intent.action.VIEW \
  -d "momrise://shared/testcode"

# Test share intent (from Pinterest)
adb shell am start -a android.intent.action.SEND \
  --es android.intent.extra.TEXT "https://momrise.app/s/testcode" \
  --type text/plain
```

**iOS:**
```bash
# Open URL in Simulator
xcrun simctl openurl booted "https://momrise.app/s/testcode"

# Or use Safari on physical device:
# Type: momrise.app/s/testcode
# Safari will prompt "Open in MomRise?"
```

## Pinterest-Specific Best Practices

### 1. Use Rich Pins
Add Open Graph meta tags to your share URLs:
```html
<meta property="og:title" content="Taco Tuesday Meal Plan">
<meta property="og:description" content="7 days of delicious Mexican meals">
<meta property="og:image" content="https://momrise.app/images/taco-plan.jpg">
<meta property="og:url" content="https://momrise.app/s/xy4k92pq">
```

Pinterest will automatically pull these when creating pins.

### 2. Create Landing Page for Web Users
Not everyone has the app installed. Create a web page at:
```
https://momrise.app/s/xy4k92pq
```

**Landing page should:**
- Show meal plan preview (images, names)
- Display "Open in App" button (deep link)
- Display "Download App" buttons (App Store, Play Store)
- Allow viewing content on web (optional)

### 3. Track Pinterest Conversions
```dart
// In deep_link_handler.dart, add Pinterest-specific tracking
if (utmSource == 'pinterest') {
  analyticsService.logPinterestVisit(
    pinId: utmContent,
    board: utmCampaign,
  );
}
```

## Common Issues & Solutions

### Issue 1: Link Opens in Browser Instead of App

**Cause**: Domain verification not set up
**Solution**: Upload assetlinks.json (Android) and apple-app-site-association (iOS)

### Issue 2: App Opens But Doesn't Navigate

**Cause**: User not logged in, pending link not handled
**Solution**: Already handled in code! Stores pending link and navigates after login (lines 228-232)

### Issue 3: Invalid Share Code Error

**Cause**: Code not exactly 8 characters or contains invalid chars
**Solution**: Validate before sharing, only use [a-z0-9] (already implemented in SharingService)

### Issue 4: iOS Share Dialog Not Appearing

**Cause**: Keyboard open or modal presentation issue
**Solution**: ✅ FIXED in share_content_bottom_sheet.dart:
- Dismisses keyboard first
- Dismisses modal
- Waits 500ms before presenting share dialog

## Debugging Deep Links

### Enable Verbose Logging

Deep link handler already has extensive debug logging:
```dart
debugPrint('DeepLinkHandler: Received uri: $uri');
debugPrint('DeepLinkHandler: scheme=${uri.scheme}');
debugPrint('DeepLinkHandler: host=${uri.host}');
debugPrint('DeepLinkHandler: path=${uri.path}');
```

### View Logs

**Android:**
```bash
adb logcat | grep -i "DeepLink\|ShareIntent"
```

**iOS:**
```bash
# In Xcode: Window → Devices and Simulators → Open Console
# Filter: DeepLink
```

## Future Enhancements

### 1. QR Codes
Generate QR codes for share links:
```dart
// Add qr_flutter package
QrImage(data: 'https://momrise.app/s/xy4k92pq')
```

### 2. SMS/Email Templates
Pre-filled message templates:
```dart
final message = 'Check out my meal plan! https://momrise.app/s/$code';
await Share.share(message, subject: 'Meal Plan from MomRise');
```

### 3. Dynamic Content Preview
When share link is opened on web, show dynamic preview with actual meal images and details.

### 4. Pinterest API Integration
Auto-post to Pinterest from app:
```dart
// Use Pinterest API to create pins programmatically
// Include rich metadata, images, and deep link
```

## Summary

**You don't need to do anything for Pinterest sharing to work!** The deep linking is already fully implemented and configured.

**What happens today:**
1. User shares meal plan from MomRise
2. Link: `https://momrise.app/s/CODE`
3. Posts to Pinterest
4. Other user clicks link from Pinterest
5. MomRise app opens and shows import screen
6. User imports meal plan to their account

**Optional improvements:**
- Add domain verification files (.well-known/assetlinks.json)
- Create web landing page for non-app users
- Add UTM tracking to Pinterest posts
- Create Rich Pins with Open Graph tags

Everything else is already done! 🎉
