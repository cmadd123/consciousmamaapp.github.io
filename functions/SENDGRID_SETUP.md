# SendGrid Setup for MomRise Waitlist Emails

## Overview
MomRise uses your existing SendGrid account (from ProjectPulse) to send waitlist welcome emails. This guide shows how to:
1. Change the "from" email to `noreply@momrise.app`
2. Deploy the Cloud Function
3. Test the email flow

---

## Step 1: Verify Domain in SendGrid (Change "From" Email)

**Current "from" email:** `noreply@projectpulsehub.com` ✅ Already verified
**Desired "from" email:** `noreply@momrise.app` ⚠️ Needs verification

### Option A: Use Existing Email (Quick Start)

**Keep using `noreply@projectpulsehub.com` for now:**

1. Update `.env` file:
   ```bash
   SENDGRID_FROM_EMAIL=noreply@projectpulsehub.com
   ```

2. Done! Your waitlist emails will come from ProjectPulse domain (users won't mind—they signed up on momrise.app)

**Pros:**
- ✅ Works immediately (domain already verified)
- ✅ Zero setup time
- ✅ Users don't care about sending domain (they see subject line)

**Cons:**
- ❌ Slightly less professional (different domain name)

---

### Option B: Verify MomRise Domain (Professional)

**To send from `noreply@momrise.app`, you need to verify the domain with SendGrid:**

#### Step 1: You Already Own momrise.app ✅
- Domain: `momrise.app`
- Website: Currently hosted at momrise.app
- No need to purchase domain

#### Step 2: Verify Domain in SendGrid

1. Log in to SendGrid: [https://app.sendgrid.com](https://app.sendgrid.com)

2. Navigate to **Settings** → **Sender Authentication**

3. Click **Authenticate Your Domain**

4. Choose your DNS host (e.g., Namecheap, GoDaddy, Cloudflare)

5. Enter domain: `momrise.app`

6. SendGrid will provide DNS records to add:
   ```
   Type: CNAME
   Host: em1234.momrise.app
   Value: u1234567.wl123.sendgrid.net

   Type: CNAME
   Host: s1._domainkey.momrise.app
   Value: s1.domainkey.u1234567.wl123.sendgrid.net

   Type: CNAME
   Host: s2._domainkey.momrise.app
   Value: s2.domainkey.u1234567.wl123.sendgrid.net
   ```

7. Add these DNS records to your domain registrar:
   - **Namecheap**: Domain List → Manage → Advanced DNS → Add Record
   - **GoDaddy**: My Products → DNS → Add Record
   - **Cloudflare**: DNS → Add Record

8. Wait 24-48 hours for DNS propagation

9. Return to SendGrid → Click **Verify** (should show green checkmark)

10. Update `.env`:
    ```bash
    SENDGRID_FROM_EMAIL=noreply@momrise.app
    ```

**Verification Status:**
- ✅ Verified: Emails will send
- ⚠️ Pending: Wait 24-48 hours, then click "Verify" again
- ❌ Failed: Check DNS records match exactly

---

## Step 2: Set SendGrid API Key in Cloud Secret Manager

**Reuse your existing SendGrid API key from ProjectPulse:**

### Option 1: Copy Key from ProjectPulse

1. Check if key exists:
   ```bash
   cd C:\Users\Administrator\Downloads\conscious_apps\projectpulse
   firebase functions:secrets:access SENDGRID_API_KEY
   ```

2. Copy the API key that appears

3. Set it for MomRise:
   ```bash
   cd C:\Users\Administrator\Downloads\mome_coach
   firebase functions:secrets:set SENDGRID_API_KEY
   ```

4. Paste the same API key when prompted

### Option 2: Get New API Key from SendGrid

If you don't have access to ProjectPulse's key:

1. Log in to SendGrid: [https://app.sendgrid.com](https://app.sendgrid.com)

2. Navigate to **Settings** → **API Keys**

3. Click **Create API Key**

4. Name: `MomRise Cloud Functions`

5. Permissions: **Full Access** (or minimum: Mail Send)

6. Click **Create & View**

7. **COPY THE KEY** (you won't see it again!)

8. Set it in Firebase:
   ```bash
   cd C:\Users\Administrator\Downloads\mome_coach
   firebase functions:secrets:set SENDGRID_API_KEY
   ```

9. Paste the API key when prompted

---

## Step 3: Install Dependencies

```bash
cd C:\Users\Administrator\Downloads\mome_coach\firebase\functions
npm install
```

This installs:
- `firebase-admin` - Firestore access
- `firebase-functions` - Cloud Functions SDK
- `@sendgrid/mail` - SendGrid email library

---

## Step 4: Deploy Cloud Function

```bash
cd C:\Users\Administrator\Downloads\mome_coach
firebase deploy --only functions
```

**Expected output:**
```
✔  functions: Finished running predeploy script.
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
i  functions: preparing codebase default for deployment
i  functions: updating Node.js 22 function sendWaitlistWelcome(us-central1)...
✔  functions[sendWaitlistWelcome(us-central1)] Successful update operation.

✔  Deploy complete!
```

---

## Step 5: Deploy Firestore Rules

```bash
cd C:\Users\Administrator\Downloads\mome_coach
firebase deploy --only firestore:rules
```

This allows the landing page to write to the `waitlist` collection.

---

## Step 6: Test the Flow End-to-End

### Test 1: Form Submission

1. Open: `https://cmadd123.github.io` (or your GitHub Pages URL)

2. Enter test email: `your-email@gmail.com`

3. Click "Get Early Access"

4. **Expected:**
   - Form disappears
   - Success message shows: "You're on the list! 🎉"
   - Console log: `Waitlist signup successful: your-email@gmail.com`

### Test 2: Firestore Write

1. Open Firebase Console: [https://console.firebase.google.com](https://console.firebase.google.com)

2. Select project: `parenting-plus-7szrif`

3. Navigate to **Firestore Database** → `waitlist` collection

4. **Expected:** New document with fields:
   ```
   email: "your-email@gmail.com"
   source: "pinterest_meal_planning"
   created_at: [timestamp]
   email_sent: false
   ```

### Test 3: Cloud Function Trigger

1. Wait 5-10 seconds (function processes)

2. Refresh Firestore document

3. **Expected:** Document updated with:
   ```
   email_sent: true
   email_sent_at: [timestamp]
   ```

4. Check Cloud Functions logs:
   ```bash
   firebase functions:log --only sendWaitlistWelcome
   ```

   **Expected log:**
   ```
   Waitlist welcome email sent to your-email@gmail.com (source: pinterest_meal_planning)
   ```

### Test 4: Email Received

1. Check your inbox (including spam/promotions folder)

2. **Expected email:**
   - **From:** noreply@momrise.app (or noreply@projectpulsehub.com if using Option A)
   - **Subject:** Welcome to MomRise! Here's your free meal plan 🍽️
   - **Content:** Beautiful HTML email with gradient header, CTA button, feature list

3. Click "Download Your Free 7-Day Meal Plan" button

4. **Expected:** Links to `https://momrise.app/free-meal-plan.pdf` (you'll need to create this PDF)

---

## Step 7: Create Free Meal Plan PDF

Your welcome email links to: `https://momrise.app/free-meal-plan.pdf`

**Quick Options:**

### Option A: Host on GitHub Pages
1. Create PDF (Canva, Google Docs, Word)
2. Save as: `free-meal-plan.pdf`
3. Add to repo: `mome_coach/website/free-meal-plan.pdf`
4. Commit and push to GitHub
5. PDF will be at: `https://cmadd123.github.io/free-meal-plan.pdf`

### Option B: Host on Google Drive
1. Upload PDF to Google Drive
2. Right-click → Share → Anyone with link can view
3. Get shareable link
4. Update email HTML: Replace `https://momrise.app/free-meal-plan.pdf` with Google Drive link

### Option C: Host on Firebase Storage
1. Upload to Firebase Storage:
   ```bash
   firebase storage:upload free-meal-plan.pdf /public/free-meal-plan.pdf
   ```
2. Make public: Firebase Console → Storage → Rules
3. Get public URL
4. Update email HTML

---

## Troubleshooting

### Issue: Email Not Sending

**Check 1: SendGrid API Key**
```bash
firebase functions:secrets:access SENDGRID_API_KEY
```
Should return your API key (or error if not set)

**Check 2: Cloud Function Logs**
```bash
firebase functions:log --only sendWaitlistWelcome
```
Look for errors like:
- `"The from email does not match a verified Sender Identity"` → Domain not verified
- `"Unauthorized"` → Wrong API key
- `"Invalid email"` → Email format issue

**Check 3: Firestore Document**
If `email_error` field exists, it contains the error message.

### Issue: Domain Not Verified

**Error:** `"The from email does not match a verified Sender Identity"`

**Fix:**
1. Go to SendGrid → Settings → Sender Authentication
2. Check domain status (should be green ✓)
3. If red ✗, click "Verify" and wait 24-48 hours
4. **Temporary fix:** Use `noreply@projectpulsehub.com` in `.env`

### Issue: Firestore Permission Denied

**Error:** `"Missing or insufficient permissions"`

**Fix:**
```bash
firebase deploy --only firestore:rules
```

Then check rules allow `allow create: if true;` for `waitlist` collection.

---

## Email Sending Limits

**SendGrid Free Tier:**
- 100 emails/day (forever free)
- Sufficient for pre-launch waitlist (< 100 signups/day expected)

**If you exceed 100 signups/day:**
- Upgrade to Essentials plan: $19.95/month for 50,000 emails
- Or throttle signups (capture in Firestore, send emails next day)

---

## Next Steps

Once everything is working:

1. **Create follow-up emails:**
   - Day 3: Introduce learning paths
   - Day 7: Explain calendar integration
   - Launch day: App is live!

2. **Add unsubscribe handling:**
   - Create Firestore `unsubscribed` collection
   - Check before sending follow-up emails

3. **Track email opens:**
   - SendGrid provides open/click tracking
   - View stats: SendGrid → Analytics

---

## Quick Reference

**Commands:**
```bash
# Deploy functions
firebase deploy --only functions

# Deploy rules
firebase deploy --only firestore:rules

# View logs
firebase functions:log --only sendWaitlistWelcome

# Set API key
firebase functions:secrets:set SENDGRID_API_KEY

# Test locally (emulator)
firebase emulators:start --only functions,firestore
```

**File Locations:**
- Cloud Function: `firebase/functions/index.js`
- Email template: Inside `index.js` (HTML string)
- SendGrid config: `firebase/functions/.env`
- Firestore rules: `mome_coach/firestore.rules`

---

**Need help?** Check SendGrid docs: https://docs.sendgrid.com/for-developers/sending-email/authentication
