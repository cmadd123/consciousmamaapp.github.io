# Share Extension Not Appearing - Troubleshooting Guide

## Problem
The "MomRise" or "Skills & Hobbies" option is not appearing in the iOS share sheet when sharing from Pinterest or other apps.

## Solution Steps (Try in order)

### Step 1: Complete App Deletion and Reinstall
iOS caches Share Extension registrations. You MUST completely remove the app for the Share Extension to register.

1. **Delete the app completely:**
   - Long press the MomRise app icon
   - Tap "Remove App" → "Delete App"
   - Confirm deletion

2. **Restart your iPhone:**
   - Power off completely
   - Wait 10 seconds
   - Power back on

3. **Reinstall from TestFlight:**
   - Open TestFlight
   - Install MomRise
   - Open the app once to activate it

4. **Test the Share Extension:**
   - Open Pinterest
   - Find any pin with a recipe
   - Tap the share icon
   - Look for "MomRise" in the share sheet
   - If not visible initially, scroll down to "More" and look for it there

### Step 2: Enable Share Extension Manually (If Not Appearing)

If "MomRise" doesn't appear in the share sheet:

1. **Access iOS Share Settings:**
   - Open Pinterest (or any app)
   - Tap the share button on any content
   - Scroll to the bottom of the share sheet
   - Tap "Edit Actions" or "More"

2. **Enable MomRise:**
   - Look for "MomRise" in the list
   - Toggle it ON
   - Drag it to the top for easy access

3. **Test again:**
   - Share a Pinterest pin
   - "MomRise" should now appear

### Step 3: Check iOS Version
Share Extensions require iOS 8.0+, but work best on iOS 13+.

- Go to Settings → General → About
- Check "Software Version"
- If below iOS 13, consider updating

### Step 4: Verify It's a TestFlight Build
Some Share Extension features are limited in TestFlight:

1. Check that you installed via TestFlight (not Xcode direct install)
2. Make sure the build number matches the latest TestFlight build
3. Try on a different device if available

## What Should Happen When Working

1. **In Pinterest:**
   - Tap share button on any pin
   - See "MomRise" option in share sheet
   - Tap "MomRise"
   - Brief "Importing recipe to MomRise..." message appears
   - App opens with recipe import page
   - Recipe details pre-filled

2. **In Safari/Chrome:**
   - Visit a recipe blog (AllRecipes, Food Network, etc.)
   - Tap share button
   - See "MomRise" option
   - Tap it to import the recipe

## Still Not Working?

If none of the above steps work:

1. **Check App Groups are enabled:**
   - This is a developer setting, should be configured already
   - Bundle ID: `com.momrise.app.ShareExtension`
   - App Group: `group.com.momrise.app`

2. **Try a different source:**
   - Instead of Pinterest, try sharing from:
     - Safari (visit allrecipes.com)
     - Notes app (select text and share)
     - Photos app (share an image)
   - This helps identify if the issue is Pinterest-specific or Share Extension-wide

3. **Check for iOS restrictions:**
   - Settings → Screen Time → Content & Privacy Restrictions
   - Make sure "Allow Extensions" is enabled

## Technical Details (For Developer)

**Share Extension Configuration:**
- Display Name: `MomRise`
- Bundle ID: `com.momrise.app.ShareExtension`
- Activation Rule: Supports web URLs (max 1) and text
- Extension Point: `com.apple.share-services`
- App Group: `group.com.momrise.app`

**Files Involved:**
- `ios/ShareExtension/Info.plist` - Extension configuration
- `ios/ShareExtension/ShareViewController.swift` - Extension UI and logic
- `ios/ShareExtension/ShareExtension.entitlements` - App Groups permission

**Known Working:**
- Pinterest sharing (after app reinstall)
- Safari recipe blogs
- Text sharing from any app
