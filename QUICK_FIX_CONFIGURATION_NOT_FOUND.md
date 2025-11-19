# Quick Fix: CONFIGURATION_NOT_FOUND Error

This error means Firebase Phone Authentication is not properly configured. Follow these steps **in order**:

## ✅ Step 1: Enable Phone Authentication (2 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/project/login-page-1c7d3/authentication/providers)
2. Click **Authentication** → **Sign-in method** (in left sidebar)
3. Find **Phone** in the list
4. Click on **Phone**
5. Toggle **Enable** to ON
6. Click **Save**

## ✅ Step 2: Get Your SHA Fingerprints (5 minutes)

### Method 1: Using Android Studio (Easiest)

1. Open Android Studio
2. Open your project: `flutter_application_1`
3. Open the **Gradle** panel (right side)
4. Navigate to: `flutter_application_1` → `android` → `Tasks` → `android` → `signingReport`
5. Double-click **signingReport**
6. Look at the **Run** output at the bottom
7. Find lines like:
   ```
   SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   ```
8. **Copy both values** (you'll need them in Step 3)

### Method 2: Using Command Line (If Android Studio doesn't work)

**Windows:**
```powershell
cd "C:\Users\shrad\OneDrive\Documents\Desktop\Test assignment\flutter_application_1"
flutter build apk --debug
```

Then check the build output for SHA fingerprints, OR:

1. Open Android Studio
2. Go to **Build** → **Generate Signed Bundle / APK**
3. Choose **Android App Bundle** or **APK**
4. Click **Create new...** (even if you don't use it, this shows your keystore info)
5. Or use the signingReport task as described in Method 1

### Method 3: Manual Keytool (If keystore exists)

```powershell
# First, check if debug keystore exists
Test-Path "$env:USERPROFILE\.android\debug.keystore"

# If it exists, get fingerprints:
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## ✅ Step 3: Add SHA Fingerprints to Firebase (3 minutes)

1. Go to [Firebase Console - Project Settings](https://console.firebase.google.com/project/login-page-1c7d3/settings/general)
2. Scroll down to **Your apps** section
3. Find your **Android app** (package name: `com.example.flutter_application_1`)
4. Click **Add fingerprint** button
5. Paste your **SHA-1** fingerprint (from Step 2)
6. Click **Add fingerprint** button again
7. Paste your **SHA-256** fingerprint (from Step 2)
8. Click **Save** (at the bottom of the page)

## ✅ Step 4: Download Updated google-services.json (1 minute)

1. Still in Firebase Console → Project Settings
2. Scroll to **Your apps** → **Android app**
3. Click **Download google-services.json**
4. **Replace** the file at: `android/app/google-services.json` with the downloaded file

## ✅ Step 5: Wait and Restart (2 minutes)

1. **Wait 2-5 minutes** for Firebase changes to propagate
2. **Fully close** your app (not just minimize)
3. **Clean and rebuild:**
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

## ✅ Step 6: Test with Test Phone Number (Optional - for development)

To avoid using real SMS during development:

1. Go to Firebase Console → **Authentication** → **Sign-in method** → **Phone**
2. Scroll to **Phone numbers for testing**
3. Click **Add phone number**
4. Add:
   - **Phone number:** `+919096405852`
   - **Verification code:** `123456`
5. Click **Save**
6. Now when you use `+919096405852` in your app, it will automatically verify with code `123456`

## 🔍 Verification Checklist

Before testing, make sure:

- [ ] Phone Authentication is **Enabled** in Firebase Console
- [ ] SHA-1 fingerprint is added to Firebase
- [ ] SHA-256 fingerprint is added to Firebase
- [ ] `google-services.json` is updated (downloaded after adding fingerprints)
- [ ] Waited 2-5 minutes after Firebase changes
- [ ] App is fully closed and restarted
- [ ] Flutter clean and rebuild done

## 🚨 Still Getting the Error?

1. **Double-check Firebase Console:**
   - Authentication → Sign-in method → Phone should show "Enabled"
   - Project Settings → Your apps → Android app should show your SHA fingerprints

2. **Verify Package Name:**
   - Check `android/app/build.gradle.kts` - should have `applicationId = "com.example.flutter_application_1"`
   - Must match exactly in Firebase Console

3. **Check Logcat for more details:**
   ```powershell
   flutter run
   # Then check the console output for more error details
   ```

4. **Try a different phone number:**
   - Use the test phone number you configured in Step 6
   - Or try a different real number

5. **Firebase Project Plan:**
   - For **production** phone auth, you need **Blaze (pay-as-you-go)** plan
   - For **development/testing**, Spark (free) plan works with test phone numbers

## 📞 Need More Help?

- Check `FIREBASE_SETUP.md` for detailed troubleshooting
- Firebase Console → Authentication → Usage tab shows authentication attempts and errors
- Android Logcat shows detailed error messages



