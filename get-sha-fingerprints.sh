#!/bin/bash
# Bash script to get SHA-1 and SHA-256 fingerprints for Android
# This will help you add them to Firebase Console

echo "Getting SHA fingerprints for Android app..."
echo ""

# Default debug keystore location
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ ! -f "$DEBUG_KEYSTORE" ]; then
    echo "Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "Creating debug keystore..."
    
    # Create the .android directory if it doesn't exist
    mkdir -p "$HOME/.android"
    
    # Generate debug keystore
    keytool -genkey -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass android -keypass android \
        -dname "CN=Android Debug,O=Android,C=US"
fi

echo "Debug Keystore Location: $DEBUG_KEYSTORE"
echo ""
echo "SHA Fingerprints:"
echo "================="
echo ""

# Get SHA-1
echo "SHA-1:"
keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey \
    -storepass android -keypass android | grep "SHA1:"
echo ""

# Get SHA-256
echo "SHA-256:"
keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey \
    -storepass android -keypass android | grep "SHA256:"
echo ""

echo "================="
echo ""
echo "Next Steps:"
echo "1. Go to Firebase Console: https://console.firebase.google.com/project/login-page-1c7d3/settings/general"
echo "2. Scroll to 'Your apps' section"
echo "3. Find your Android app (com.example.flutter_application_1)"
echo "4. Click 'Add fingerprint' and paste the SHA-1 value above"
echo "5. Click 'Add fingerprint' again and paste the SHA-256 value above"
echo "6. Click 'Save'"
echo "7. Download the updated google-services.json and replace android/app/google-services.json"
echo "8. Wait 2-5 minutes for changes to propagate"
echo "9. Restart your app"
echo ""

