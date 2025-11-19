import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/auth_errors.dart';
import '../../core/services/cloud_functions_service.dart';
import '../../core/services/crypto_service.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/firestore_user_service.dart';
import '../../core/services/pin_storage_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    cloudFunctions: ref.watch(cloudFunctionsServiceProvider),
    tokenStorage: ref.watch(tokenStorageServiceProvider),
    pinStorage: ref.watch(pinStorageServiceProvider),
    cryptoService: ref.watch(cryptoServiceProvider),
    firestoreUserService: ref.watch(firestoreUserServiceProvider),
  );
});

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuthService authService,
    required CloudFunctionsService cloudFunctions,
    required TokenStorageService tokenStorage,
    required PinStorageService pinStorage,
    required CryptoService cryptoService,
    required FirestoreUserService firestoreUserService,
  })  : _authService = authService,
        _cloudFunctions = cloudFunctions,
        _tokenStorage = tokenStorage,
        _pinStorage = pinStorage,
        _cryptoService = cryptoService,
        _firestoreUserService = firestoreUserService;

  final FirebaseAuthService _authService;
  final CloudFunctionsService _cloudFunctions;
  final TokenStorageService _tokenStorage;
  final PinStorageService _pinStorage;
  final CryptoService _cryptoService;
  final FirestoreUserService _firestoreUserService;

  @override
  Future<RequestOtpModel> requestOtp({
    required String phoneNumber,
  }) async {
    final response = await _authService.requestOtp(phoneNumber);
    return RequestOtpModel(verificationId: response.verificationId);
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final credential = await _authService.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Unable to sign in with provided code.');
    }
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Unable to obtain Firebase ID token.');
    }
    final jwt = await _cloudFunctions.issueJwt(idToken: idToken);
    await _tokenStorage.persist(
      token: jwt.jwt,
      expiresAt: jwt.expiresAt,
      phoneNumber: phoneNumber,
    );
    final hasPin = await _firestoreUserService.userHasPin(user.uid);
    return VerifyOtpResult(
      profile: jwt.profile,
      requiresPinSetup: !hasPin,
    );
  }

  @override
  Future<VerifyOtpResult> setPin({
    required String phoneNumber,
    required String pin,
  }) async {
    final salt = _cryptoService.generateSalt();
    final iterations = _cryptoService.defaultIterations;
    final hash = _cryptoService.hashPin(
      pin: pin,
      salt: salt,
      iterations: iterations,
    );
    await _pinStorage.persist(
      StoredPin(
        phoneNumber: phoneNumber,
        hash: hash,
        salt: salt,
        iterations: iterations,
      ),
    );
    final response = await _cloudFunctions.setPin(
      phoneNumber: phoneNumber,
      pinHash: hash,
      salt: salt,
      iterations: iterations,
    );
    await _tokenStorage.persist(
      token: response.jwt,
      expiresAt: response.expiresAt,
      phoneNumber: phoneNumber,
    );
    return VerifyOtpResult(
      profile: response.profile,
      requiresPinSetup: false,
    );
  }

  @override
  Future<VerifyOtpResult> loginWithPin({
    required String pin,
  }) async {
    final storedPin = await _pinStorage.read();
    if (storedPin == null) {
      throw MissingPinException();
    }
    final hash = _cryptoService.hashPin(
      pin: pin,
      salt: storedPin.salt,
      iterations: storedPin.iterations,
    );
    if (hash != storedPin.hash) {
      throw PinMismatchException();
    }
    final result = await _cloudFunctions.loginWithPin(
      phoneNumber: storedPin.phoneNumber,
      pinHash: hash,
    );
    await _authService.signInWithCustomToken(result.customToken);
    await _tokenStorage.persist(
      token: result.jwt,
      expiresAt: result.expiresAt,
      phoneNumber: storedPin.phoneNumber,
    );
    return VerifyOtpResult(
      profile: result.profile,
      requiresPinSetup: false,
    );
  }

  @override
  Future<UserProfile> fetchProfile() async {
    final storedToken = await _tokenStorage.read();
    if (storedToken == null) {
      throw Exception('Not authenticated');
    }
    return _cloudFunctions.fetchProfile(jwt: storedToken.token);
  }

  @override
  Future<void> logout() async {
    await _authService.signOut();
    await _tokenStorage.clear();
    await _pinStorage.clear();
  }
}

