# Fix: reCAPTCHA Error & SMS Not Sending

## Problem
- Error: `Failed to initialize reCAPTCHA config: No Recaptcha Enterprise siteKey configured`
- SMS is not being sent
- User appears in Firebase Authentication but OTP never arrives

## Root Cause
Firebase Phone Authentication requires reCAPTCHA verification. This is automatically configured when you add SHA fingerprints to Firebase, but your `google-services.json` shows empty `oauth_client` array, meaning the fingerprints haven't been added yet.

## Solution Steps

### Step 1: Add SHA Fingerprints to Firebase (CRITICAL)

Your SHA fingerprints are:
- **SHA-1:** `62:54:DB:20:5B:98:FF:7E:A4:59:D9:0D:D6:FB:A0:B6:17:C5:1C:A2`
- **SHA-256:** `28:10:A2:33:D4:4A:68:E1:60:09:87:1A:5F:15:20:9A:CF:B1:20:5D:54:47:0E:A2:CC:AD:39:37:A1:11:CB:96`

**Do this now:**

1. Go to [Firebase Console - Project Settings](https://console.firebase.google.com/project/test-assignment-67647/settings/general)
   - Your project ID is: `test-assignment-67647`
   
2. Scroll down to **"Your apps"** section

3. Find your **Android app** (package: `com.example.flutter_application_1`)

4. Click **"Add fingerprint"** button

5. Paste the **SHA-1** fingerprint:
   ```
   62:54:DB:20:5B:98:FF:7E:A4:59:D9:0D:D6:FB:A0:B6:17:C5:1C:A2
   ```

6. Click **"Add fingerprint"** button again

7. Paste the **SHA-256** fingerprint:
   ```
   28:10:A2:33:D4:4A:68:E1:60:09:87:1A:5F:15:20:9A:CF:B1:20:5D:54:47:0E:A2:CC:AD:39:37:A1:11:CB:96
   ```

8. Click **"Save"** at the bottom

### Step 2: Re-download google-services.json

**IMPORTANT:** After adding fingerprints, you MUST re-download `google-services.json`:

1. Still in Firebase Console → Project Settings
2. Scroll to **"Your apps"** → **Android app**
3. Click **"Download google-services.json"**
4. **Replace** the file at: `android/app/google-services.json` with the new file

The new file should have `oauth_client` entries with reCAPTCHA configuration.

### Step 3: Enable Phone Authentication (if not already done)

1. Go to [Firebase Console - Authentication](https://console.firebase.google.com/project/test-assignment-67647/authentication/providers)
2. Click **"Sign-in method"** tab
3. Find **"Phone"** in the list
4. Click on **"Phone"**
5. Toggle **"Enable"** to ON
6. Click **"Save"**

### Step 4: Wait and Rebuild

1. **Wait 3-5 minutes** for Firebase changes to propagate
2. **Fully close** your app (not just minimize)
3. Clean and rebuild:
   ```powershell
   flutter clean
   flutter pub get
   cd android
   .\gradlew clean
   cd ..
   flutter run
   ```

### Step 5: Test with Test Phone Number (Recommended for Development)

To avoid waiting for real SMS during testing:

1. Go to Firebase Console → **Authentication** → **Sign-in method** → **Phone**
2. Scroll to **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Add:
   - **Phone number:** `+919096405852`
   - **Verification code:** `123456`
5. Click **"Save"**

Now when you use `+919096405852` in your app, Firebase will automatically accept code `123456` without sending SMS.

## Verification

After completing the steps above:

1. The reCAPTCHA error should disappear
2. SMS should be sent successfully (or use test number)
3. OTP verification should work

## Still Having Issues?

1. **Check Firebase Console:**
   - Authentication → Sign-in method → Phone should show "Enabled"
   - Project Settings → Your apps → Android app should show both SHA fingerprints
   - The `google-services.json` should have `oauth_client` entries (not empty array)

2. **Verify google-services.json:**
   - Open `android/app/google-services.json`
   - Look for `oauth_client` array - it should NOT be empty `[]`
   - It should contain entries with `client_type: 3` (reCAPTCHA)

3. **Check Firebase Project Plan:**
   - For **production** SMS, you need **Blaze (pay-as-you-go)** plan
   - For **development/testing**, Spark (free) plan works with test phone numbers

4. **Wait longer:**
   - Firebase changes can take up to 10 minutes to fully propagate
   - Try again after waiting

