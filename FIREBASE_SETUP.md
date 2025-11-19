# Firebase Phone Authentication Setup Guide

## Error: CONFIGURATION_NOT_FOUND

This error occurs when Firebase Phone Authentication is not properly configured. Follow these steps to fix it:

## Step 1: Enable Phone Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **login-page-1c7d3**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Phone** provider
5. **Enable** Phone Authentication
6. Click **Save**

## Step 2: Add SHA-1 and SHA-256 Fingerprints (Android)

Firebase requires your app's SHA fingerprints to verify the app's identity. You need to add both **debug** and **release** fingerprints.

### Get SHA Fingerprints

#### Option A: Using Gradle (Recommended)

Run this command in your project root:

**Windows (PowerShell):**
```powershell
cd android
.\gradlew signingReport
```

**Linux/Mac:**
```bash
cd android
./gradlew signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

#### Option B: Using Keytool (Manual)

**For Debug Keystore:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Keystore (if you have one):**
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your-key-alias
```

### Add Fingerprints to Firebase

1. Go to Firebase Console → **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your Android app (package: `com.example.flutter_application_1`)
4. Click **Add fingerprint**
5. Paste the **SHA-1** fingerprint
6. Click **Add fingerprint** again and paste the **SHA-256** fingerprint
7. Click **Save**

**Important:** Add BOTH debug and release SHA fingerprints if you plan to build a release version.

## Step 3: Verify App Package Name

Make sure your app's package name matches Firebase:

1. Check `android/app/build.gradle.kts` - should have:
   ```kotlin
   applicationId = "com.example.flutter_application_1"
   ```

2. In Firebase Console → Project Settings → Your apps, verify the package name matches.

## Step 4: Download Updated google-services.json

After adding SHA fingerprints:

1. Go to Firebase Console → Project Settings
2. Scroll to **Your apps** → Android app
3. Click **Download google-services.json**
4. Replace `android/app/google-services.json` with the new file

## Step 5: Clean and Rebuild

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## Step 6: Test Phone Authentication

1. Run the app: `flutter run`
2. Enter a phone number (use a real number for testing, or Firebase Test Phone Numbers)
3. The OTP should be sent successfully

## Using Firebase Test Phone Numbers (Development)

For testing without real SMS, you can use Firebase's test phone numbers:

1. Go to Firebase Console → Authentication → Sign-in method → Phone
2. Scroll to **Phone numbers for testing**
3. Add test numbers with verification codes:
   - Phone: `+919096405852`
   - Code: `123456`
4. Use these in your app for testing

## Troubleshooting

### Still Getting CONFIGURATION_NOT_FOUND?

1. **Wait a few minutes** - Firebase changes can take 2-5 minutes to propagate
2. **Check Firebase Console** - Ensure Phone Authentication shows as "Enabled"
3. **Verify SHA fingerprints** - Make sure they're added correctly (no spaces, correct format)
4. **Check package name** - Must match exactly: `com.example.flutter_application_1`
5. **Re-download google-services.json** - After adding SHA fingerprints
6. **Restart the app** - Fully close and reopen the app

### For Production/Release Builds

When building for release, you MUST add your release keystore's SHA fingerprints:

1. Generate release keystore (if not exists):
   ```bash
   keytool -genkey -v -keystore android/app/release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Get SHA fingerprints from release keystore
3. Add them to Firebase Console
4. Update `android/app/build.gradle.kts` with release signing config

## Quick Checklist

- [ ] Phone Authentication enabled in Firebase Console
- [ ] SHA-1 fingerprint added to Firebase
- [ ] SHA-256 fingerprint added to Firebase
- [ ] Package name matches (`com.example.flutter_application_1`)
- [ ] `google-services.json` is up to date
- [ ] App cleaned and rebuilt
- [ ] Waited 2-5 minutes after Firebase changes

## Still Having Issues?

1. Check Firebase Console → Authentication → Usage tab for any errors
2. Check Android Logcat for more detailed error messages
3. Verify your Firebase project has the Blaze plan (required for Phone Auth in production)
4. For development, the Spark (free) plan works with test phone numbers

