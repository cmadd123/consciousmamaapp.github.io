# MomRise Admin Scripts

Local command-line tools for provisioning creators and similar one-off
admin tasks. Not deployed anywhere — these run from your machine against
production Firestore using a service-account key.

## One-time setup

1. **Download a service account key**
   - Firebase Console → Project settings → Service accounts → Generate new private key
   - Save it as `admin/service-account.json` (this directory). It's gitignored.

2. **Install dependencies**
   ```bash
   cd admin
   npm install
   ```

## Usage

### List pending creator applications

```bash
node approve-creator.js
```

Prints every `creator_applications` doc with `status == 'new'`, sorted newest first.

### Approve an application

```bash
node approve-creator.js <applicationId>
```

- Looks up the Firebase user by the email on the application.
- If no matching user is found, prompts you for the UID manually.
- Generates a unique creator code (e.g. `HALEY42`).
- Creates a `creators/{autoId}` doc with MomRise-default theme colors.
- Marks the application as `approved` with a timestamp.
- Prints a welcome-email body for you to paste into your mail client.

If the applicant hasn't created a Firebase account yet, have them sign up
in the MomRise app first, then come back here and pass `--uid` with the
UID from the Firebase Auth console.

### Reject an application

```bash
node approve-creator.js <applicationId> --reject
```

Marks the application as `rejected` with a timestamp. No email is
generated — send your own rejection note.

### Override the UID lookup

```bash
node approve-creator.js <applicationId> --uid <firebaseUid>
```

Skips the email-based lookup and uses the UID you pass. Useful when the
applicant's Firebase-Auth email doesn't match the email they submitted
with.
