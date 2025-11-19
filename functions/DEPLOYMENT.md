# Cloud Functions Deployment Guide

This guide will help you deploy the Firebase Cloud Functions required for the Flutter authentication app.

## Prerequisites

1. **Node.js** (version 18 or higher) - [Download](https://nodejs.org/)
2. **Firebase CLI** - Install globally:
   ```bash
   npm install -g firebase-tools
   ```
3. **Firebase Project** - Make sure you have a Firebase project set up (your project ID: `login-page-1c7d3`)

## Setup Steps

### 1. Login to Firebase

```bash
firebase login
```

### 2. Initialize Firebase Functions (if not already done)

Navigate to the project root and run:

```bash
firebase init functions
```

When prompted:
- Select **TypeScript** as the language
- Use **ESLint** (optional, but recommended)
- Install dependencies now? **Yes**

### 3. Install Dependencies

Navigate to the `functions` directory:

```bash
cd functions
npm install
```

### 4. Set JWT Secret (IMPORTANT for Production)

For production, you should set the JWT secret as a Firebase environment variable:

```bash
firebase functions:config:set jwt.secret="your-very-secure-random-string-here"
```

Or use Firebase Secret Manager (recommended for production):

```bash
firebase functions:secrets:set JWT_SECRET
# Enter your secret when prompted
```

Then update `functions/src/index.ts` to use:
```typescript
const JWT_SECRET = process.env.JWT_SECRET || functions.config().jwt?.secret || 'fallback-secret';
```

### 5. Build the Functions

```bash
npm run build
```

This compiles TypeScript to JavaScript in the `lib/` directory.

### 6. Deploy Functions

From the project root directory:

```bash
firebase deploy --only functions
```

Or deploy specific functions:

```bash
firebase deploy --only functions:authIssueJwt,functions:authSetPin,functions:authLoginWithPin,functions:authFetchProfile
```

## Testing Locally (Optional)

You can test functions locally using the Firebase Emulator:

```bash
# Start emulators
firebase emulators:start --only functions

# In another terminal, test a function
curl -X POST http://localhost:5001/login-page-1c7d3/us-central1/authIssueJwt \
  -H "Content-Type: application/json" \
  -d '{"data": {"idToken": "your-test-token"}}'
```

## Functions Overview

### 1. `authIssueJwt`
- **Purpose**: Issues a JWT token after OTP verification
- **Input**: `{ idToken: string }` (Firebase ID token)
- **Output**: `{ jwt: string, expiresAt: string, profile: UserProfile }`

### 2. `authSetPin`
- **Purpose**: Sets a PIN for a user after OTP verification
- **Input**: `{ phoneNumber: string, pinHash: string, salt: string, iterations: number }`
- **Output**: `{ jwt: string, expiresAt: string, profile: UserProfile }`

### 3. `authLoginWithPin`
- **Purpose**: Authenticates a user using their PIN
- **Input**: `{ phoneNumber: string, pinHash: string }`
- **Output**: `{ jwt: string, expiresAt: string, profile: UserProfile, customToken: string }`

### 4. `authFetchProfile`
- **Purpose**: Fetches user profile using a JWT token
- **Input**: `{ jwt: string }`
- **Output**: `UserProfile`
- **Error**: Returns error if JWT is invalid or expired

## Firestore Security Rules

Make sure your Firestore security rules allow authenticated users to read/write their own user document:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Error: "Functions did not deploy"
- Check that you're logged in: `firebase login`
- Verify project: `firebase use login-page-1c7d3`
- Check Node.js version: `node --version` (should be 18+)

### Error: "JWT verification failed"
- Make sure JWT_SECRET is set correctly
- Check that the secret matches between function calls

### Error: "User not found"
- Ensure Firebase Authentication is enabled
- Verify phone authentication is enabled in Firebase Console

## Monitoring

View function logs:

```bash
firebase functions:log
```

Or view in Firebase Console: https://console.firebase.google.com/project/login-page-1c7d3/functions

## Next Steps

After deployment:
1. Test the functions from your Flutter app
2. Monitor function logs for any errors
3. Set up proper JWT secret management for production
4. Configure Firestore security rules
5. Enable billing if needed (Cloud Functions require Blaze plan)

