import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as jwt from 'jsonwebtoken';

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// JWT secret key - Use Firebase Secret Manager for production
// Set it with: firebase functions:secrets:set JWT_SECRET
// Or use config: firebase functions:config:set jwt.secret="your-secret"
const JWT_SECRET = 
  process.env.JWT_SECRET || 
  functions.config().jwt?.secret || 
  'your-secret-key-change-in-production';
const JWT_EXPIRY_HOURS = 24;

interface UserProfile {
  uid: string;
  phoneNumber?: string;
  displayName?: string;
  email?: string;
  issuedAt?: string;
}

interface IssueJwtResponse {
  jwt: string;
  expiresAt: string;
  profile: UserProfile;
}

interface LoginWithPinResponse {
  jwt: string;
  expiresAt: string;
  profile: UserProfile;
  customToken: string;
}

/**
 * Issues a JWT token after OTP verification
 * Expects: { idToken: string } (Firebase ID token from OTP verification)
 */
export const authIssueJwt = functions.https.onCall(async (data, context) => {
  try {
    // Verify the Firebase ID token
    const idToken = data.idToken;
    if (!idToken || typeof idToken !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'idToken is required'
      );
    }

    // Verify the ID token
    const decodedToken = await auth.verifyIdToken(idToken);
    const uid = decodedToken.uid;
    const phoneNumber = decodedToken.phone_number;

    // Get user document from Firestore
    const userDoc = await db.collection('users').doc(uid).get();
    const userData = userDoc.data();

    // Create user profile
    const profile: UserProfile = {
      uid,
      phoneNumber: phoneNumber || undefined,
      displayName: userData?.displayName || decodedToken.name || undefined,
      email: decodedToken.email || undefined,
      issuedAt: new Date().toISOString(),
    };

    // Create JWT token
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + JWT_EXPIRY_HOURS);

    const tokenPayload = {
      uid,
      phoneNumber: profile.phoneNumber,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(expiresAt.getTime() / 1000),
    };

    const jwtToken = jwt.sign(tokenPayload, JWT_SECRET);

    // Update or create user document
    await db.collection('users').doc(uid).set(
      {
        ...profile,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    const response: IssueJwtResponse = {
      jwt: jwtToken,
      expiresAt: expiresAt.toISOString(),
      profile,
    };

    return response;
  } catch (error: any) {
    console.error('Error in authIssueJwt:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to issue JWT'
    );
  }
});

/**
 * Sets a PIN for a user after OTP verification
 * Expects: { phoneNumber: string, pinHash: string, salt: string, iterations: number }
 */
export const authSetPin = functions.https.onCall(async (data, context) => {
  try {
    const { phoneNumber, pinHash, salt, iterations } = data;

    if (!phoneNumber || !pinHash || !salt || !iterations) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'phoneNumber, pinHash, salt, and iterations are required'
      );
    }

    // Find user by phone number
    let user;
    try {
      user = await auth.getUserByPhoneNumber(phoneNumber);
    } catch (error: any) {
      throw new functions.https.HttpsError(
        'not-found',
        'User not found for this phone number'
      );
    }

    const uid = user.uid;

    // Store PIN hash in Firestore
    await db.collection('users').doc(uid).set(
      {
        pinHash,
        salt,
        iterations,
        hasPin: true,
        phoneNumber,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Create user profile
    const profile: UserProfile = {
      uid,
      phoneNumber,
      displayName: user.displayName || undefined,
      email: user.email || undefined,
      issuedAt: new Date().toISOString(),
    };

    // Issue JWT token
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + JWT_EXPIRY_HOURS);

    const tokenPayload = {
      uid,
      phoneNumber,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(expiresAt.getTime() / 1000),
    };

    const jwtToken = jwt.sign(tokenPayload, JWT_SECRET);

    const response: IssueJwtResponse = {
      jwt: jwtToken,
      expiresAt: expiresAt.toISOString(),
      profile,
    };

    return response;
  } catch (error: any) {
    console.error('Error in authSetPin:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to set PIN'
    );
  }
});

/**
 * Logs in a user with PIN
 * Expects: { phoneNumber: string, pinHash: string }
 */
export const authLoginWithPin = functions.https.onCall(async (data, context) => {
  try {
    const { phoneNumber, pinHash } = data;

    if (!phoneNumber || !pinHash) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'phoneNumber and pinHash are required'
      );
    }

    // Find user by phone number
    let user;
    try {
      user = await auth.getUserByPhoneNumber(phoneNumber);
    } catch (error: any) {
      throw new functions.https.HttpsError(
        'not-found',
        'User not found for this phone number'
      );
    }

    const uid = user.uid;

    // Get user document from Firestore
    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'User document not found'
      );
    }

    const userData = userDoc.data();
    if (!userData) {
      throw new functions.https.HttpsError(
        'not-found',
        'User data not found'
      );
    }

    // Verify PIN hash
    const storedPinHash = userData.pinHash;
    if (!storedPinHash || storedPinHash !== pinHash) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid PIN'
      );
    }

    // Check if user has PIN set
    if (!userData.hasPin) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'PIN not set for this user'
      );
    }

    // Create custom token for Firebase Auth
    const customToken = await auth.createCustomToken(uid);

    // Create user profile
    const profile: UserProfile = {
      uid,
      phoneNumber,
      displayName: user.displayName || userData.displayName || undefined,
      email: user.email || userData.email || undefined,
      issuedAt: new Date().toISOString(),
    };

    // Issue JWT token
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + JWT_EXPIRY_HOURS);

    const tokenPayload = {
      uid,
      phoneNumber,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(expiresAt.getTime() / 1000),
    };

    const jwtToken = jwt.sign(tokenPayload, JWT_SECRET);

    const response: LoginWithPinResponse = {
      jwt: jwtToken,
      expiresAt: expiresAt.toISOString(),
      profile,
      customToken,
    };

    return response;
  } catch (error: any) {
    console.error('Error in authLoginWithPin:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to login with PIN'
    );
  }
});

/**
 * Fetches user profile using JWT token
 * Expects: { jwt: string }
 */
export const authFetchProfile = functions.https.onCall(async (data, context) => {
  try {
    const { jwt: jwtToken } = data;

    if (!jwtToken || typeof jwtToken !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'JWT token is required'
      );
    }

    // Verify JWT token
    let decoded: any;
    try {
      decoded = jwt.verify(jwtToken, JWT_SECRET);
    } catch (error: any) {
      if (error.name === 'TokenExpiredError') {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'JWT token has expired'
        );
      }
      if (error.name === 'JsonWebTokenError') {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'Invalid JWT token'
        );
      }
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Failed to verify JWT token'
      );
    }

    const uid = decoded.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Invalid token payload'
      );
    }

    // Get user from Auth
    let user;
    try {
      user = await auth.getUser(uid);
    } catch (error: any) {
      throw new functions.https.HttpsError(
        'not-found',
        'User not found'
      );
    }

    // Get user document from Firestore
    const userDoc = await db.collection('users').doc(uid).get();
    const userData = userDoc.data();

    // Create user profile
    const profile: UserProfile = {
      uid,
      phoneNumber: decoded.phoneNumber || user.phoneNumber || undefined,
      displayName: user.displayName || userData?.displayName || undefined,
      email: user.email || userData?.email || undefined,
      issuedAt: new Date().toISOString(),
    };

    return profile;
  } catch (error: any) {
    console.error('Error in authFetchProfile:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to fetch profile'
    );
  }
});

