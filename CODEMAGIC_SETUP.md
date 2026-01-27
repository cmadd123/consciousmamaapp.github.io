# Codemagic Setup Guide for MomRise

This guide walks you through setting up Codemagic CI/CD for automated iOS builds to TestFlight.

## Prerequisites

✅ App created in App Store Connect with Bundle ID `com.momrise.app`
✅ Bundle ID registered in Apple Developer Portal
✅ GitHub repository connected to Codemagic

---

## Step 1: Create App Store Connect API Key

This allows Codemagic to upload builds to TestFlight automatically.

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click **"+"** to create a new key
3. Fill in:
   - **Name:** Codemagic CI/CD
   - **Access:** App Manager (or Developer if you want more control)
4. Click **Generate**
5. **Download the API Key** (.p8 file) - You can only download this ONCE!
6. **Save these values** (you'll need them in Codemagic):
   - **Issuer ID:** (shown at top of page, looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
   - **Key ID:** (shown in the key row, looks like: `XXXXXXXXXX`)
   - **API Key File:** The .p8 file you downloaded

---

## Step 2: Create iOS Distribution Certificate

Codemagic needs a certificate to sign your app.

### Option A: Let Codemagic Generate (Easiest)

1. In Codemagic, go to **Teams → Code signing identities**
2. Click **"iOS certificates"**
3. Click **"Generate certificate"**
4. Codemagic will automatically create and manage the certificate

### Option B: Use Existing Certificate (Manual)

If you already have a certificate:

1. Export it from Xcode or Keychain Access as a .p12 file
2. Upload to Codemagic in **Teams → Code signing identities → iOS certificates**
3. Enter the certificate password

---

## Step 3: Set Up Provisioning Profile

1. In Codemagic, go to **Teams → Code signing identities → iOS provisioning profiles**
2. Click **"Fetch profiles from Apple Developer Portal"**
3. Codemagic will automatically fetch profiles for `com.momrise.app`
4. If no profile exists, Codemagic can create one automatically

---

## Step 4: Configure Codemagic App Settings

1. Go to https://codemagic.io/apps
2. Click **"Add application"**
3. Select your GitHub repository: `consciousmamaapp.github.io`
4. Choose the Flutter project
5. Click **"Finish: Add application"**

---

## Step 5: Add Environment Variables in Codemagic

Go to your app in Codemagic → **Environment variables** and add these:

### App Store Connect Credentials

Create a new group called `app_store_credentials`:

1. **APP_STORE_CONNECT_ISSUER_ID**
   - Value: Your Issuer ID from Step 1
   - Type: Secure (encrypted)

2. **APP_STORE_CONNECT_KEY_IDENTIFIER**
   - Value: Your Key ID from Step 1
   - Type: Secure (encrypted)

3. **APP_STORE_CONNECT_PRIVATE_KEY**
   - Value: Contents of your .p8 file from Step 1
   - Open the .p8 file in a text editor and copy the ENTIRE contents including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`
   - Type: Secure (encrypted)

### Certificate Private Key

4. **CERTIFICATE_PRIVATE_KEY**
   - If you're using Codemagic-generated certificates, this is handled automatically
   - If using your own certificate, add the .p12 password here
   - Type: Secure (encrypted)

---

## Step 6: Update Your Email in codemagic.yaml

Open `codemagic.yaml` and replace the placeholder email:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # ← Replace with your actual email
```

---

## Step 7: Trigger Your First Build

### Option A: Push to GitHub (Automatic)

Simply push any commit to the `main` branch:

```bash
git add codemagic.yaml
git commit -m "Configure Codemagic for TestFlight"
git push
```

Codemagic will automatically detect the push and start building.

### Option B: Manual Trigger

1. Go to Codemagic → Your app → **Start new build**
2. Select the `ios-workflow`
3. Click **"Start new build"**

---

## Step 8: Monitor Build Progress

1. Watch the build in Codemagic's dashboard
2. You'll see each step execute:
   - ✓ Set up code signing
   - ✓ Get Flutter packages
   - ✓ Install CocoaPods
   - ✓ Build iOS IPA
   - ✓ Upload to TestFlight
3. Build time: ~10-15 minutes

---

## Step 9: Check TestFlight

After the build succeeds:

1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"** → **"MomRise"**
3. Click **"TestFlight"** tab
4. You should see your build processing (takes 5-10 minutes for Apple to process)
5. Once processing completes, you can distribute to testers

---

## Common Issues & Solutions

### Build Fails: "Invalid Bundle ID"

**Solution:** Make sure you created the app in App Store Connect with Bundle ID `com.momrise.app`

### Build Fails: "Code signing error"

**Solution:**
1. Check that your certificate and provisioning profile are valid
2. Make sure the profile includes `com.momrise.app`
3. Try letting Codemagic auto-generate the certificate

### Build Fails: "API Key invalid"

**Solution:**
1. Verify you copied the ENTIRE .p8 file contents (including BEGIN/END lines)
2. Check that Issuer ID and Key ID are correct
3. Make sure the API key has "App Manager" access

### TestFlight Upload Fails

**Solution:**
1. Verify the app exists in App Store Connect
2. Make sure the Bundle ID matches exactly: `com.momrise.app`
3. Check that your API key has upload permissions

---

## Version Numbers

Codemagic automatically increments the build number for each build:

- **Build Name:** 1.1.128 (you can change this in codemagic.yaml line 50)
- **Build Number:** Auto-incremented (1, 2, 3, ...)

To change the version:

```yaml
flutter build ipa --release \
  --build-name=1.2.0 \  # ← Change this
  --build-number=$(($(app-store-connect get-latest-testflight-build-number "$APP_STORE_CONNECT_ISSUER_ID" "$BUNDLE_ID") + 1))
```

---

## TestFlight Beta Groups

After your first build uploads, create a beta group in App Store Connect:

1. Go to **TestFlight** → **Internal Group** or **External Testing**
2. Click **"+"** to create a new group
3. Name it: `Internal Testers`
4. Add testers (up to 100 internal, unlimited external)

Future builds will automatically be distributed to this group.

---

## Disabling Automatic Builds

If you want to manually trigger builds instead of auto-building on every push:

Edit `codemagic.yaml` and remove or comment out the triggering section:

```yaml
# triggering:
#   events:
#     - push
#   branch_patterns:
#     - pattern: main
#       include: true
#       source: true
```

---

## Associated Domains for Deep Linking

Before submitting to App Review, you'll need to add Associated Domains in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj!)
2. Select the **Runner** target
3. Click **"Signing & Capabilities"**
4. Click **"+ Capability"** → **"Associated Domains"**
5. Add these domains:
   - `applinks:momrise.app`
   - `applinks:cmadd123.github.io`

This allows deep linking from your website to the app.

---

## Next Steps After First Build

1. ✅ Wait for build to complete (~10-15 min)
2. ✅ Wait for Apple to process the build (~5-10 min)
3. ✅ Add internal testers in TestFlight
4. ✅ Test the app on real devices via TestFlight
5. ✅ Take App Store screenshots (5 required)
6. ✅ Fill in App Store metadata (description, keywords, etc.)
7. ✅ Submit for App Review

---

## Useful Links

- **Codemagic Dashboard:** https://codemagic.io/apps
- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight:** https://appstoreconnect.apple.com → My Apps → MomRise → TestFlight
- **Codemagic Docs:** https://docs.codemagic.io/flutter-configuration/yaml/

---

## Cost

Codemagic pricing:
- **Free tier:** 500 build minutes/month
- **Pro tier:** $95/month - unlimited builds
- Each iOS build takes ~10-15 minutes
- **Estimate:** ~30-50 builds/month on free tier

For production apps, the Pro tier is recommended for faster builds and unlimited minutes.
