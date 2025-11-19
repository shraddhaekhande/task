# Simple script to get SHA fingerprints for Firebase
# This script will guide you through getting your SHA-1 and SHA-256 fingerprints

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase SHA Fingerprint Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Java/keytool is available
$keytoolPath = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytoolPath) {
    Write-Host "⚠️  keytool not found in PATH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please use one of these methods instead:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "METHOD 1: Android Studio (Recommended)" -ForegroundColor Green
    Write-Host "1. Open Android Studio" -ForegroundColor White
    Write-Host "2. Open your project" -ForegroundColor White
    Write-Host "3. Open Gradle panel (right side)" -ForegroundColor White
    Write-Host "4. Navigate to: android > Tasks > android > signingReport" -ForegroundColor White
    Write-Host "5. Double-click signingReport" -ForegroundColor White
    Write-Host "6. Check the Run output for SHA1 and SHA256" -ForegroundColor White
    Write-Host ""
    Write-Host "METHOD 2: Flutter Build" -ForegroundColor Green
    Write-Host "Run: flutter build apk --debug" -ForegroundColor White
    Write-Host "Check the output for SHA fingerprints" -ForegroundColor White
    Write-Host ""
    exit 0
}

# Check for debug keystore
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"
Write-Host "Looking for debug keystore at: $debugKeystore" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $debugKeystore)) {
    Write-Host "⚠️  Debug keystore not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The debug keystore will be created automatically when you:" -ForegroundColor Yellow
    Write-Host "1. Build your Flutter app for the first time, OR" -ForegroundColor White
    Write-Host "2. Run: flutter build apk --debug" -ForegroundColor White
    Write-Host ""
    Write-Host "After building, run this script again to get your SHA fingerprints." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "✅ Found debug keystore!" -ForegroundColor Green
Write-Host ""
Write-Host "Getting SHA fingerprints..." -ForegroundColor Cyan
Write-Host ""

try {
    # Get SHA-1
    $sha1Output = keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android 2>&1 | Select-String "SHA1:"
    
    # Get SHA-256
    $sha256Output = keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android 2>&1 | Select-String "SHA256:"
    
    if ($sha1Output -and $sha256Output) {
        # Extract just the fingerprint values
        $sha1 = ($sha1Output -split "SHA1:")[1].Trim()
        $sha256 = ($sha256Output -split "SHA256:")[1].Trim()
        
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SHA-1 Fingerprint:" -ForegroundColor Yellow
        Write-Host $sha1 -ForegroundColor White
        Write-Host ""
        Write-Host "SHA-256 Fingerprint:" -ForegroundColor Yellow
        Write-Host $sha256 -ForegroundColor White
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Go to Firebase Console:" -ForegroundColor White
        Write-Host "   https://console.firebase.google.com/project/login-page-1c7d3/settings/general" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Scroll to 'Your apps' section" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Find your Android app (com.example.flutter_application_1)" -ForegroundColor White
        Write-Host ""
        Write-Host "4. Click 'Add fingerprint' and paste SHA-1:" -ForegroundColor White
        Write-Host "   $sha1" -ForegroundColor Gray
        Write-Host ""
        Write-Host "5. Click 'Add fingerprint' again and paste SHA-256:" -ForegroundColor White
        Write-Host "   $sha256" -ForegroundColor Gray
        Write-Host ""
        Write-Host "6. Click 'Save'" -ForegroundColor White
        Write-Host ""
        Write-Host "7. Download updated google-services.json and replace:" -ForegroundColor White
        Write-Host "   android/app/google-services.json" -ForegroundColor Gray
        Write-Host ""
        Write-Host "8. Wait 2-5 minutes, then restart your app" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "❌ Could not extract SHA fingerprints from keystore" -ForegroundColor Red
        Write-Host "Try using Android Studio method instead (see above)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error reading keystore: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try using Android Studio method instead:" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio" -ForegroundColor White
    Write-Host "2. Gradle panel > android > Tasks > android > signingReport" -ForegroundColor White
}



