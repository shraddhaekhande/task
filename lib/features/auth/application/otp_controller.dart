import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import '../../../router/navigation_service.dart';
import 'auth_flow_notifier.dart';

final otpControllerProvider =
    StateNotifierProvider<OtpController, AsyncValue<void>>((ref) {
  return OtpController(
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    authFlowNotifier: ref.read(authFlowProvider.notifier),
    navigationService: ref.read(navigationServiceProvider),
  );
});

class OtpController extends StateNotifier<AsyncValue<void>> {
  OtpController({
    required this.verifyOtpUseCase,
    required this.authFlowNotifier,
    required this.navigationService,
  }) : super(const AsyncData(null));

  final VerifyOtpUseCase verifyOtpUseCase;
  final AuthFlowNotifier authFlowNotifier;
  final NavigationService navigationService;

  Future<void> verifyOtp({required String code}) async {
    final flowState = authFlowNotifier.state;
    final verificationId = flowState.verificationId;
    final phoneNumber = flowState.phoneNumber;
    if (verificationId == null || phoneNumber == null) {
      state = AsyncError(
        StateError('Missing verification id. Please request a new OTP.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await verifyOtpUseCase(
        verificationId: verificationId,
        smsCode: code,
        phoneNumber: phoneNumber,
      );
      authFlowNotifier.setRequiresPin(result.requiresPinSetup);
      if (result.requiresPinSetup) {
        navigationService.goToPinSetup();
      } else {
        navigationService.goHome();
      }
    });
  }
}

