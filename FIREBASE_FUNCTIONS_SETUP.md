# Firebase Cloud Functions Setup Instructions for HandSpeak

This guide explains how to set up Firebase Cloud Functions to enable email verification for the HandSpeak app.

## 1. Prerequisites

- Firebase CLI installed (`npm install -g firebase-tools`)
- Node.js version 18 or higher
- Firebase project already created (handspeak-ace26)

## 2. Setting Email Configuration

Before deploying, you need to set your email password as a secret configuration:

```bash
firebase functions:config:set email.password="YOUR_GMAIL_APP_PASSWORD"
```

**Note:** For security, use a Gmail App Password, not your regular password. You can generate one in your Google Account settings.

## 3. Testing Functions Locally

To test the functions locally:

```bash
cd functions
npm run serve
```

This will start the Firebase emulators.

## 4. Deploying to Firebase

To deploy the functions to Firebase:

```bash
firebase deploy --only functions
```

## 5. Function Details

### sendVerificationEmail
- Triggered when a document is created in the `mail_queue` collection
- Sends an email with a verification code
- Updates document status after sending

### cleanupVerificationCodes
- Runs every 24 hours
- Deletes expired verification codes from the database

### cleanupMailQueue
- Runs every 7 days
- Cleans up old email records from the queue

## 6. Email Templates

Currently, there is one email template:

- `verification`: Used for sending verification codes

You can add more templates by extending the `getEmailTemplate` function in `functions/index.js`.

## 7. Integration with HandSpeak App

The Flutter app is already set up to create documents in the `mail_queue` collection. When a user requests email verification, the app creates a document with:

```
{
  to: "user@example.com",
  template: "verification",
  code: "123456",
  createdAt: timestamp
}
```

The Cloud Function then handles sending the actual email.
