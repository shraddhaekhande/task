import '../repositories/auth_repository.dart';

class LoginWithPinUseCase {
  LoginWithPinUseCase(this._repository);

  final AuthRepository _repository;

  Future<VerifyOtpResult> call(String pin) {
    return _repository.loginWithPin(pin: pin);
  }
}

