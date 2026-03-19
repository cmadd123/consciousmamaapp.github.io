# Verify momrise.app Domain in SendGrid

## Quick Guide: Change From Email to noreply@momrise.app

Since you already own `momrise.app`, you just need to verify it with SendGrid to send emails from `noreply@momrise.app`.

---

## Step 1: Log in to SendGrid

1. Go to: [https://app.sendgrid.com](https://app.sendgrid.com)
2. Log in with your credentials (same account as ProjectPulse)

---

## Step 2: Authenticate Your Domain

1. Click **Settings** (left sidebar)
2. Click **Sender Authentication**
3. Click **Authenticate Your Domain** button

4. **Domain Settings:**
   - Domain You Send From: `momrise.app`
   - Would you also like to brand the links for this domain? **Yes** (recommended)

5. **DNS Host:**
   - Select where your domain's DNS is managed:
     - Namecheap
     - GoDaddy
     - Cloudflare
     - Custom (if other)

6. Click **Next**

---

## Step 3: Add DNS Records

SendGrid will provide 3 CNAME records like this:

```
Type: CNAME
Host: em1234.momrise.app
Points to: u1234567.wl123.sendgrid.net
TTL: Automatic

Type: CNAME
Host: s1._domainkey.momrise.app
Points to: s1.domainkey.u1234567.wl123.sendgrid.net
TTL: Automatic

Type: CNAME
Host: s2._domainkey.momrise.app
Points to: s2.domainkey.u1234567.wl123.sendgrid.net
TTL: Automatic
```

**Note:** Your actual values will be different—copy from SendGrid dashboard.

---

## Step 4: Add Records to Your Domain Registrar

### If using Namecheap:

1. Log in to Namecheap
2. Domain List → Find `momrise.app` → Click **Manage**
3. Click **Advanced DNS** tab
4. Click **Add New Record**
5. For each CNAME record:
   - **Type:** CNAME Record
   - **Host:** (e.g., `em1234` or `s1._domainkey`)
   - **Value:** (e.g., `u1234567.wl123.sendgrid.net`)
   - **TTL:** Automatic
6. Click **Save All Changes**

### If using GoDaddy:

1. Log in to GoDaddy
2. My Products → DNS → Manage DNS
3. Add Record → Select **CNAME**
4. For each CNAME record:
   - **Name:** (e.g., `em1234` or `s1._domainkey`)
   - **Value:** (e.g., `u1234567.wl123.sendgrid.net`)
   - **TTL:** 1 hour (or default)
5. Click **Save**

### If using Cloudflare:

1. Log in to Cloudflare
2. Select `momrise.app` domain
3. Click **DNS** tab
4. Click **Add Record**
5. For each CNAME record:
   - **Type:** CNAME
   - **Name:** (e.g., `em1234` or `s1._domainkey`)
   - **Target:** (e.g., `u1234567.wl123.sendgrid.net`)
   - **Proxy status:** DNS only (grey cloud)
   - **TTL:** Auto
6. Click **Save**

**Important:** Turn OFF Cloudflare proxy (grey cloud, not orange) for email DNS records.

---

## Step 5: Verify in SendGrid

1. Wait 10-15 minutes for DNS propagation (can take up to 48 hours)
2. Return to SendGrid → Sender Authentication page
3. Find your domain (`momrise.app`)
4. Click **Verify** button

**Expected Results:**
- ✅ Green checkmark = Verified! You can send from noreply@momrise.app
- ⚠️ Yellow warning = DNS not propagated yet, wait 24 hours and try again
- ❌ Red error = DNS records incorrect, double-check values match exactly

---

## Step 6: Update Firebase Function Config

Once verified:

1. Edit `firebase/functions/.env`:
   ```bash
   SENDGRID_FROM_EMAIL=noreply@momrise.app
   ```

2. Redeploy function:
   ```bash
   cd C:\Users\Administrator\Downloads\mome_coach
   firebase deploy --only functions
   ```

3. Test by submitting email on website
4. Check inbox for email from `noreply@momrise.app`

---

## Troubleshooting

### DNS Records Not Verifying

**Check DNS propagation:**
```
https://dnschecker.org
```
- Enter: `em1234.momrise.app` (replace with your actual subdomain)
- Should show CNAME pointing to SendGrid

**Common issues:**
- Forgot to add subdomain (e.g., entered `_domainkey` instead of `s1._domainkey`)
- Left Cloudflare proxy ON (needs to be DNS only)
- TTL too long (reduce to 1 hour)
- Typo in CNAME value

### Still Can't Verify After 48 Hours

1. **Remove old records** (if any exist for those subdomains)
2. **Clear DNS cache:**
   ```bash
   ipconfig /flushdns  # Windows
   ```
3. **Try again** with exact values from SendGrid
4. **Contact SendGrid support** if still failing

### Email Sends But Lands in Spam

**After domain verification, improve deliverability:**

1. **Add SPF record** (if not already):
   ```
   Type: TXT
   Host: @
   Value: v=spf1 include:sendgrid.net ~all
   ```

2. **Wait 1-2 weeks** for domain reputation to build
3. **Ask recipients to mark as "Not Spam"**
4. **Avoid spam trigger words** in subject lines

---

## Quick DNS Check Commands

**Check if DNS records are live:**

```bash
# Check em subdomain
nslookup em1234.momrise.app

# Check DKIM keys
nslookup s1._domainkey.momrise.app
nslookup s2._domainkey.momrise.app
```

**Expected output:**
```
em1234.momrise.app
canonical name = u1234567.wl123.sendgrid.net
```

If you see "Non-existent domain" → DNS not propagated yet, wait longer.

---

## Where Your DNS is Managed

**To find out where momrise.app DNS is managed:**

1. Go to: [https://whois.domaintools.com](https://whois.domaintools.com)
2. Enter: `momrise.app`
3. Look for **Name Servers** section
4. Common patterns:
   - `ns1.namecheap.com` → Managed at Namecheap
   - `ns1.godaddy.com` → Managed at GoDaddy
   - `*.ns.cloudflare.com` → Managed at Cloudflare
   - `*.domaincontrol.com` → GoDaddy

---

## Alternative: Keep Using ProjectPulse Email (Temporary)

**If you want emails working TODAY:**

1. Keep `.env` as:
   ```bash
   SENDGRID_FROM_EMAIL=noreply@projectpulsehub.com
   ```

2. Deploy and test immediately (no DNS wait time)

3. Switch to `noreply@momrise.app` later once domain verified

**Users won't care** - they signed up on momrise.app, the sending domain doesn't matter to them.

---

## Summary

**Timeline:**
- Add DNS records: 5 minutes
- DNS propagation: 10 minutes to 48 hours (usually ~1 hour)
- Verification in SendGrid: Instant once DNS propagates
- Update function + test: 5 minutes

**Total:** ~1-2 hours if DNS is fast, up to 2 days if slow.

**Recommendation:** Start verification now, use `noreply@projectpulsehub.com` temporarily until verified.
