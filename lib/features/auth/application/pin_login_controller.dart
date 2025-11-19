import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/auth_errors.dart';
import '../../../core/providers/usecase_providers.dart';
import '../../../core/services/pin_storage_service.dart';
import '../../../domain/usecases/login_with_pin_usecase.dart';
import '../../../router/navigation_service.dart';
import 'auth_flow_notifier.dart';

const _maxPinAttempts = 3;

final pinLoginControllerProvider = StateNotifierProvider<PinLoginController,
    AsyncValue<PinLoginViewState>>((ref) {
  return PinLoginController(
    loginWithPinUseCase: ref.watch(loginWithPinUseCaseProvider),
    pinStorageService: ref.watch(pinStorageServiceProvider),
    authFlowNotifier: ref.read(authFlowProvider.notifier),
    navigationService: ref.read(navigationServiceProvider),
  );
});

class PinLoginController
    extends StateNotifier<AsyncValue<PinLoginViewState>> {
  PinLoginController({
    required this.loginWithPinUseCase,
    required this.pinStorageService,
    required this.authFlowNotifier,
    required this.navigationService,
  }) : super(const AsyncLoading()) {
    _bootstrap();
  }

  final LoginWithPinUseCase loginWithPinUseCase;
  final PinStorageService pinStorageService;
  final AuthFlowNotifier authFlowNotifier;
  final NavigationService navigationService;

  Future<void> _bootstrap() async {
    final storedPin = await pinStorageService.read();
    final hasPin = storedPin != null;
    state = AsyncData(
      PinLoginViewState(
        hasStoredPin: hasPin,
        attemptsLeft: _attemptsLeft(),
        errorMessage: hasPin ? null : 'Please complete OTP login to set a PIN.',
      ),
    );
  }

  int _attemptsLeft() {
    final used = authFlowNotifier.state.failedPinAttempts;
    final remaining = _maxPinAttempts - used;
    return remaining.clamp(0, _maxPinAttempts);
  }

  Future<void> loginWithPin(String pin) async {
    final current = state.value;
    if (current == null || !current.canAttempt) {
      return;
    }
    state = const AsyncLoading();
    try {
      await loginWithPinUseCase(pin);
      authFlowNotifier.resetPinFailures();
      state = AsyncData(
        PinLoginViewState(
          hasStoredPin: true,
          attemptsLeft: _maxPinAttempts,
        ),
      );
      navigationService.goHome();
    } on PinMismatchException catch (error) {
      authFlowNotifier.incrementPinFailures();
      state = AsyncData(
        PinLoginViewState(
          hasStoredPin: true,
          attemptsLeft: _attemptsLeft(),
          errorMessage: error.message,
        ),
      );
    } on MissingPinException catch (error) {
      state = AsyncData(
        PinLoginViewState(
          hasStoredPin: false,
          attemptsLeft: _attemptsLeft(),
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      state = AsyncData(
        PinLoginViewState(
          hasStoredPin: true,
          attemptsLeft: _attemptsLeft(),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void openOtp() {
    authFlowNotifier.reset();
    navigationService.restartAuth();
  }
}

class PinLoginViewState {
  PinLoginViewState({
    required this.hasStoredPin,
    required this.attemptsLeft,
    this.errorMessage,
  });

  final bool hasStoredPin;
  final int attemptsLeft;
  final String? errorMessage;

  bool get canAttempt => hasStoredPin && attemptsLeft > 0;

  bool get hasError => errorMessage != null;
}

