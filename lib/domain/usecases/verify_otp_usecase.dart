import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<VerifyOtpResult> call({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) {
    return _repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      phoneNumber: phoneNumber,
    );
  }
}

