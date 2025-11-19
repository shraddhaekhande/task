# Secure OTP + PIN Flutter App

This Flutter application demonstrates a production-ready phone authentication flow that combines Firebase PhoneAuth OTP verification, secure PIN-based login, and JWT-protected APIs powered by Firebase Cloud Functions / Firestore.

## Capabilities

- Phone number capture with international country code picker.
- OTP send/verify using Firebase Authentication.
- Set PIN flow that hashes the PIN, stores it locally using `flutter_secure_storage`, and sends the hash + salt to a backend.
- PIN login screen with attempt tracking (hard stop after 3 failures) and an OTP fallback CTA.
- JWT storage/renewal with automatic protection of the Home screen. Expired/invalid tokens trigger a forced logout.
- Logout clears JWT, PIN secrets, and Firebase session state.

## Architecture

- **Clean Architecture** style with domain entities/repos/usecases and separate data & presentation layers.
- **State management** via Riverpod `StateNotifier`s for each screen (phone, OTP, PIN setup/login, home).
- **Routing** handled by `go_router` with a splash screen that decides whether to open Home, PIN login, or phone onboarding.
- **Security** helpers:
  - `CryptoService` applies an iterative HMAC-SHA256 hash with randomly generated salt.
  - `TokenStorageService` and `PinStorageService` wrap `flutter_secure_storage`.
- **Backend adapters**:
  - `FirebaseAuthService` for OTP and custom-token sign in.
  - `CloudFunctionsService` for `/auth/issueJwt`, `/auth/setPin`, `/auth/loginWithPin`, `/auth/fetchProfile`.
  - `FirestoreUserService` to determine whether a user has already created a PIN.

## Firebase & Backend Setup

1. **Configure Firebase**
   - Run `flutterfire configure` and ensure `firebase_options.dart` is generated.
   - Enable **Phone Authentication** in Firebase Auth.
   - Add Android & iOS config files (`google-services.json`, `GoogleService-Info.plist`), already referenced in the project.

2. **Cloud Functions** ✅ **Already Created!**
   - The Cloud Functions are already implemented in the `functions/` directory.
   - **Deploy them** by following the steps in `functions/DEPLOYMENT.md` or run:
     ```bash
     # Windows (PowerShell)
     .\deploy-functions.ps1
     
     # Linux/Mac
     ./deploy-functions.sh
     
     # Or manually:
     cd functions
     npm install
     npm run build
     cd ..
     firebase deploy --only functions
     ```
   - The functions include:
     - `authIssueJwt` - Issues JWT after OTP verification
     - `authSetPin` - Sets user PIN and stores hash in Firestore
     - `authLoginWithPin` - Authenticates with PIN, returns custom token + JWT
     - `authFetchProfile` - Fetches user profile, validates JWT expiry
   - **Important**: Set a secure JWT secret before deploying to production:
     ```bash
     firebase functions:secrets:set JWT_SECRET
     ```

3. **Firestore**
   - Store user metadata under `users/{uid}` with at minimum `hasPin`, `pinHash`, `salt`, `iterations`, and any profile details you want to surface on the Home screen.

## Running the App

```bash
flutter pub get
flutter run
```

The splash screen will route users as follows:
1. Valid JWT in secure storage → Home
2. Stored PIN secrets but no JWT → PIN login screen
3. Otherwise → Phone number onboarding

After OTP verification, new users are forced through the Set PIN flow. Existing users without a valid JWT will use the PIN login screen or choose “Login using OTP” to restart the flow.

## Testing

The default widget test is kept minimal (`test/widget_test.dart`) because the app requires Firebase-native services. Consider adding integration tests with `flutter_driver` or `integration_test` + Firebase emulators for full automation.
