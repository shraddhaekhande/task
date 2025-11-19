# Firebase Cloud Functions

This directory contains the Firebase Cloud Functions required for the Flutter authentication app.

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Build:**
   ```bash
   npm run build
   ```

3. **Deploy:**
   ```bash
   firebase deploy --only functions
   ```

## Functions

- `authIssueJwt` - Issues JWT after OTP verification
- `authSetPin` - Sets user PIN
- `authLoginWithPin` - Authenticates with PIN
- `authFetchProfile` - Fetches user profile with JWT

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

