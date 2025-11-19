# PowerShell script to get SHA-1 and SHA-256 fingerprints for Android
# This will help you add them to Firebase Console

Write-Host "Getting SHA fingerprints for Android app..." -ForegroundColor Green
Write-Host ""

# Default debug keystore location
$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $debugKeystore)) {
    Write-Host "Debug keystore not found at: $debugKeystore" -ForegroundColor Yellow
    Write-Host "Creating debug keystore..." -ForegroundColor Yellow
    
    # Create the .android directory if it doesn't exist
    $androidDir = "$env:USERPROFILE\.android"
    if (-not (Test-Path $androidDir)) {
        New-Item -ItemType Directory -Path $androidDir | Out-Null
    }
    
    # Generate debug keystore
    keytool -genkey -v -keystore $debugKeystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
}

Write-Host "Debug Keystore Location: $debugKeystore" -ForegroundColor Cyan
Write-Host ""
Write-Host "SHA Fingerprints:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow
Write-Host ""

# Get SHA-1
Write-Host "SHA-1:" -ForegroundColor Green
$sha1 = keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1:" | ForEach-Object { $_.Line.Trim() }
Write-Host $sha1 -ForegroundColor White
Write-Host ""

# Get SHA-256
Write-Host "SHA-256:" -ForegroundColor Green
$sha256 = keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android | Select-String "SHA256:" | ForEach-Object { $_.Line.Trim() }
Write-Host $sha256 -ForegroundColor White
Write-Host ""

# Extract just the fingerprint values
$sha1Value = ($sha1 -split ":")[1..2] -join ":" | ForEach-Object { $_.Trim() }
$sha256Value = ($sha256 -split ":")[1..2] -join ":" | ForEach-Object { $_.Trim() }

Write-Host "=================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to Firebase Console: https://console.firebase.google.com/project/login-page-1c7d3/settings/general" -ForegroundColor White
Write-Host "2. Scroll to 'Your apps' section" -ForegroundColor White
Write-Host "3. Find your Android app (com.example.flutter_application_1)" -ForegroundColor White
Write-Host "4. Click 'Add fingerprint' and paste the SHA-1 value above" -ForegroundColor White
Write-Host "5. Click 'Add fingerprint' again and paste the SHA-256 value above" -ForegroundColor White
Write-Host "6. Click 'Save'" -ForegroundColor White
Write-Host "7. Download the updated google-services.json and replace android/app/google-services.json" -ForegroundColor White
Write-Host "8. Wait 2-5 minutes for changes to propagate" -ForegroundColor White
Write-Host "9. Restart your app" -ForegroundColor White
Write-Host ""

