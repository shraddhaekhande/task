import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<RequestOtpModel> requestOtp({
    required String phoneNumber,
  });

  Future<VerifyOtpResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  });

  Future<VerifyOtpResult> setPin({
    required String phoneNumber,
    required String pin,
  });

  Future<VerifyOtpResult> loginWithPin({
    required String pin,
  });

  Future<UserProfile> fetchProfile();

  Future<void> logout();
}

class RequestOtpModel {
  RequestOtpModel({
    required this.verificationId,
  });

  final String verificationId;
}

class VerifyOtpResult {
  VerifyOtpResult({
    required this.profile,
    required this.requiresPinSetup,
  });

  final UserProfile profile;
  final bool requiresPinSetup;
}

