import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/usecases/fetch_profile_usecase.dart';
import '../../domain/usecases/login_with_pin_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

final requestOtpUseCaseProvider = Provider<RequestOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RequestOtpUseCase(repository);
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyOtpUseCase(repository);
});

final setPinUseCaseProvider = Provider<SetPinUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SetPinUseCase(repository);
});

final loginWithPinUseCaseProvider = Provider<LoginWithPinUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithPinUseCase(repository);
});

final fetchProfileUseCaseProvider = Provider<FetchProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return FetchProfileUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

