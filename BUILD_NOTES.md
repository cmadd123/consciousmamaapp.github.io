# MomRise Build Notes

## Build History

### Build 1 - Initial TestFlight Release (2026-01-27)

**Codemagic Setup Complete:**
- Bundle ID: com.momrise.app
- App Store Connect API configured
- iOS Distribution Certificate generated
- Automatic builds enabled on push to main

**App Configuration:**
- App Name: MomRise
- Version: 1.1.128
- Bundle ID: com.momrise.app
- Custom Domain: momrise.app

**Features in This Build:**
- AI-powered learning path creation
- Milestone tracking
- Activity suggestions
- Meal planning
- Family calendar
- Content sharing via momrise.app/s/{code}
- Deep linking support (Android only)

**Known Limitations:**
- iOS Universal Links NOT included (will be in Build 2)
- Share links will open in Safari on iOS until Build 2

**Next Steps After Build:**
1. Wait for Codemagic build to complete (~10-15 minutes)
2. Wait for Apple to process build (~5-10 minutes)
3. Add internal testers in TestFlight
4. Test on real devices
5. Take App Store screenshots
6. Trigger Build 2 with iOS Universal Links support

---

### Build 2 - iOS Universal Links (Pending)

**What's New:**
- iOS Associated Domains configured
- Universal Links: applinks:momrise.app
- Universal Links: applinks:cmadd123.github.io
- Share links now open directly in app on iOS

**Status:** Ready to build once Build 1 is tested

**Next Steps:**
1. Test Build 1 thoroughly
2. Trigger new build to include Universal Links
3. Test share link flow on iOS
4. Submit for App Review
