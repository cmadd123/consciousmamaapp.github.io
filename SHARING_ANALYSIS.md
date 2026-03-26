# Sharing Features - Comprehensive Analysis

## Overview
MomRise has extensive sharing functionality that allows users to share meal plans, recipes, activities, and learning paths via custom URLs (momrise.app/s/CODE).

## iOS-Specific Implementation

### Critical iOS Handling (lines 534-540 in share_content_bottom_sheet.dart)
```dart
// On iOS, dismiss the bottom sheet first — iOS can't present
// UIActivityViewController from within another presented modal.
if (Platform.isIOS && mounted) {
  Navigator.of(context).pop();
  // Wait for the dismiss animation to complete
  await Future.delayed(const Duration(milliseconds: 350));
}
```

**Why this matters:**
- iOS doesn't allow presenting `UIActivityViewController` (the share dialog) from within a modal bottom sheet
- The code MUST dismiss the bottom sheet first
- There's a 350ms delay to let the dismiss animation complete
- This is a **platform limitation**, not a bug

## Sharing Flow

### 1. Create Share Link (lines 396-516)
```
User taps "Create Share Link"
  → Creates SharedContentRecord in Firestore with 8-char code
  → Generates URL: https://momrise.app/s/abcd1234
  → Auto-triggers native share dialog (line 504)
```

### 2. Native Share Dialog (lines 530-566)
```dart
Future<void> _shareViaSystem() async {
  if (_shareCode == null || _shareUrl == null) return;

  try {
    // iOS: Dismiss bottom sheet FIRST
    if (Platform.isIOS && mounted) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Call share_plus package
    await SharingService.shareViaSystem(
      shareCode: _shareCode!,
      title: widget.title,
      description: widget.description,
    );

    // Android: Show success message AFTER sharing
    if (!Platform.isIOS && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(...);
      Navigator.of(context).pop();
    }
  } catch (e) {
    // Fallback: Copy to clipboard
    Clipboard.setData(ClipboardData(text: _shareUrl!));
  }
}
```

## Potential iOS Issues

### Issue 1: Timing Problems
**Symptom**: Share dialog doesn't appear, or app crashes
**Cause**: 350ms delay may be too short/long depending on device performance
**Solution**:
- Monitor for crashes in Crashlytics
- Could increase delay to 500ms for older devices
- Could use completion callback instead of fixed delay

### Issue 2: Modal Context Issues
**Symptom**: Share works sometimes, fails other times
**Cause**: iOS modal presentation stack gets confused
**Solution**:
- Ensure no other modals are presented when sharing
- Check if keyboard is dismissed before sharing
- Verify `mounted` state before calling Navigator.pop

### Issue 3: share_plus Package Version
**Current**: Using `share_plus` package (lines 1444-1447 in sharing_service.dart)
```dart
await Share.share(
  text,
  subject: title,
);
```
**Check**: Verify share_plus version is up-to-date (iOS 17+ compatibility)

## All Sharing Features

### 1. Meal Plan Sharing (sharing_service.dart lines 23-155)
- Shares week of meals (breakfast/lunch/dinner)
- Supports meal combos (entree + sides + drinks)
- Personal note optional
- Preview shows all meals grouped by day

### 2. Single Day Sharing (lines 158-277)
- Shares all meals for one day
- Same data structure as meal plan but date_offset always 0

### 3. Single Meal Sharing (lines 280-382)
- Shares one meal slot (breakfast, lunch, OR dinner)
- Can be single recipe or combo
- Shows meal type and preview

### 4. Single Recipe Sharing (lines 385-436)
- From cookbook (not meal plan)
- Just the recipe data

### 5. Single Combo Sharing (lines 439-522)
- Meal template with entree + sides + desserts + drink
- From cookbook

### 6. Learning Path Sharing (lines 525-576)
- Educational paths for kids
- Includes all tasks

### 7. Activity Sharing (lines 579-650)
- User-created activities
- Includes duration, materials, safety notes

### 8. Activity Plan Sharing (lines 653-735)
- Week of activities (7 days)
- Multiple activities per day

### 9. Day Template Sharing (lines 738-855)
- Saved day with breakfast + lunch + dinner templates
- Used for recurring meal patterns

## Share URL Structure

### URL Format
```
https://momrise.app/s/abcd1234
```

### Share Code Generation (lines 15-19)
```dart
static String _generateShareCode() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
}
```
- 8 characters: lowercase + numbers only
- Cryptographically secure random
- Checks for duplicates before saving

### URL Extraction (lines 958-987)
Supports multiple URL formats:
- `momrise.app/s/code` (primary)
- `momrise.app/shared/code` (legacy)
- `cmadd123.github.io/s/code` (GitHub Pages fallback)
- Direct 8-char codes

## Firestore Schema

### SharedContentRecord (shared_content_record.dart)
```dart
{
  share_code: "abcd1234",          // 8-char code
  content_type: SharedContentType,  // mealPlan, activity, learningPath, etc.
  shared_by_user: DocumentReference,
  shared_by_name: "Jane Doe",
  title: "Week of Delicious Meals",
  description: "7 meals planned",
  preview_image: "https://...",     // First meal image
  content_data: {                   // JSON with full content
    meals: [...],
    personal_note: "Hope you enjoy!"
  },
  created_at: Timestamp,
  view_count: 0,
  import_count: 0,
  is_active: true
}
```

## Debugging iOS Share Issues

### Check 1: Crashlytics Logs
Look for errors related to:
- `UIActivityViewController`
- Modal presentation
- share_plus package
- Navigator state

### Check 2: Test Scenarios
1. **Share from meal planner** → Works/Fails?
2. **Share from cookbook** → Works/Fails?
3. **Share with keyboard open** → Works/Fails?
4. **Share after other modals** → Works/Fails?
5. **Share on different iOS versions** → Works/Fails?

### Check 3: Common Patterns
When does it fail?
- Only on first share attempt?
- Only after X shares?
- Only with certain content types?
- Only when bottom sheet is scrolled?
- Only when personal note is added?

### Check 4: share_plus Package
```bash
flutter pub outdated
flutter pub upgrade share_plus
```

## Recommended Fixes

### Fix 1: Increase iOS Delay
```dart
// Change from 350ms to 500ms
await Future.delayed(const Duration(milliseconds: 500));
```

### Fix 2: Use Completion Callback
```dart
if (Platform.isIOS && mounted) {
  await Navigator.of(context).maybePop();
  // Wait for pop to actually complete
  await Future.delayed(Duration(milliseconds: 100));
  await Navigator.of(context).maybePop(); // Ensure fully dismissed
  await Future.delayed(const Duration(milliseconds: 400));
}
```

### Fix 3: Dismiss Keyboard First
```dart
if (Platform.isIOS && mounted) {
  // Dismiss keyboard before anything else
  FocusScope.of(context).unfocus();
  await Future.delayed(const Duration(milliseconds: 100));

  Navigator.of(context).pop();
  await Future.delayed(const Duration(milliseconds: 350));
}
```

### Fix 4: Check Modal Stack
```dart
if (Platform.isIOS && mounted) {
  // Dismiss ALL modals to ensure clean state
  while (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 50));
  }
  await Future.delayed(const Duration(milliseconds: 200));
}
```

## Files to Review

1. **lib/custom_code/actions/sharing_service.dart** - All sharing logic
2. **lib/components/share_content_bottom_sheet.dart** - Share UI + iOS handling
3. **lib/v2/shared/import_shared_content_widget.dart** - Import shared content
4. **lib/flutter_flow/share_intent_handler.dart** - Deep link handling
5. **lib/backend/schema/shared_content_record.dart** - Firestore schema

## Next Steps

1. **Enable verbose logging** in share_content_bottom_sheet.dart:
```dart
print('DEBUG: About to dismiss modal (iOS)');
Navigator.of(context).pop();
print('DEBUG: Modal dismissed, waiting 350ms');
await Future.delayed(const Duration(milliseconds: 350));
print('DEBUG: Delay complete, calling Share.share');
await SharingService.shareViaSystem(...);
print('DEBUG: Share.share completed');
```

2. **Test on multiple iOS versions:**
   - iOS 15, 16, 17, 18
   - Different device types (iPhone SE, iPhone 15 Pro Max)

3. **Monitor specific error patterns:**
   - Does it fail on first share?
   - Does it fail after rotating device?
   - Does it fail when app is in background?

4. **Check share_plus GitHub issues:**
   - Search for iOS-specific bugs
   - Check if others have modal presentation issues
