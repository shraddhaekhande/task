import '../repositories/auth_repository.dart';

class RequestOtpUseCase {
  RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<RequestOtpModel> call(String phoneNumber) {
    return _repository.requestOtp(phoneNumber: phoneNumber);
  }
}

