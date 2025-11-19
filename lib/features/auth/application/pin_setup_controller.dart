import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../domain/usecases/set_pin_usecase.dart';
import '../../../router/navigation_service.dart';
import 'auth_flow_notifier.dart';

final pinSetupControllerProvider =
    StateNotifierProvider<PinSetupController, AsyncValue<void>>((ref) {
  return PinSetupController(
    setPinUseCase: ref.watch(setPinUseCaseProvider),
    authFlowNotifier: ref.read(authFlowProvider.notifier),
    navigationService: ref.read(navigationServiceProvider),
  );
});

class PinSetupController extends StateNotifier<AsyncValue<void>> {
  PinSetupController({
    required this.setPinUseCase,
    required this.authFlowNotifier,
    required this.navigationService,
  }) : super(const AsyncData(null));

  final SetPinUseCase setPinUseCase;
  final AuthFlowNotifier authFlowNotifier;
  final NavigationService navigationService;

  Future<void> setPin(String pin) async {
    final phoneNumber = authFlowNotifier.state.phoneNumber;
    if (phoneNumber == null) {
      state = AsyncError(
        StateError('Phone number missing in session'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await setPinUseCase(pin: pin, phoneNumber: phoneNumber);
      authFlowNotifier.setRequiresPin(false);
      navigationService.goHome();
    });
  }
}

