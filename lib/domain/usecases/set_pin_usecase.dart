import '../repositories/auth_repository.dart';

class SetPinUseCase {
  SetPinUseCase(this._repository);

  final AuthRepository _repository;

  Future<VerifyOtpResult> call({
    required String pin,
    required String phoneNumber,
  }) {
    return _repository.setPin(
      phoneNumber: phoneNumber,
      pin: pin,
    );
  }
}

