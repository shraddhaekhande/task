import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../domain/usecases/request_otp_usecase.dart';
import '../../../router/navigation_service.dart';
import 'auth_flow_notifier.dart';

final phoneAuthControllerProvider =
    StateNotifierProvider<PhoneAuthController, AsyncValue<void>>((ref) {
  return PhoneAuthController(
    requestOtpUseCase: ref.watch(requestOtpUseCaseProvider),
    authFlowNotifier: ref.read(authFlowProvider.notifier),
    navigationService: ref.read(navigationServiceProvider),
  );
});

class PhoneAuthController extends StateNotifier<AsyncValue<void>> {
  PhoneAuthController({
    required this.requestOtpUseCase,
    required this.authFlowNotifier,
    required this.navigationService,
  }) : super(const AsyncData(null));

  final RequestOtpUseCase requestOtpUseCase;
  final AuthFlowNotifier authFlowNotifier;
  final NavigationService navigationService;

  Future<void> requestOtp({required String phoneNumber}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await requestOtpUseCase(phoneNumber);
      authFlowNotifier.startPhoneVerification(
        phoneNumber: phoneNumber,
        verificationId: result.verificationId,
      );
      navigationService.goToOtp();
    });
  }
}

