import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/pin_storage_service.dart';
import '../core/services/token_storage_service.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_number_screen.dart';
import '../features/auth/presentation/screens/pin_login_screen.dart';
import '../features/auth/presentation/screens/set_pin_screen.dart';
import '../features/home/presentation/home_screen.dart';
import 'app_router.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  final router = ref.watch(appRouterProvider);
  return NavigationService(
    router: router,
    tokenStorage: ref.read(tokenStorageServiceProvider),
    pinStorageService: ref.read(pinStorageServiceProvider),
  );
});

class NavigationService {
  NavigationService({
    required GoRouter router,
    required TokenStorageService tokenStorage,
    required PinStorageService pinStorageService,
  })  : _router = router,
        _tokenStorage = tokenStorage,
        _pinStorageService = pinStorageService;

  final GoRouter _router;
  final TokenStorageService _tokenStorage;
  final PinStorageService _pinStorageService;

  Future<void> goToInitialAuthStep() async {
    final hasValidJwt = await _tokenStorage.hasValidToken();
    if (hasValidJwt) {
      _router.go(HomeScreen.routePath);
      return;
    }
    final storedPin = await _pinStorageService.read();
    if (storedPin != null) {
      _router.go(PinLoginScreen.routePath);
      return;
    }
    _router.go(PhoneNumberScreen.routePath);
  }

  void goToOtp() => _router.go(OtpScreen.routePath);

  void goToPinSetup() => _router.go(SetPinScreen.routePath);

  void goToPinLogin() => _router.go(PinLoginScreen.routePath);

  void goHome() => _router.go(HomeScreen.routePath);

  void restartAuth() =>
      _router.go(PhoneNumberScreen.routePath);
}

