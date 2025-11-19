import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_number_screen.dart';
import '../features/auth/presentation/screens/pin_login_screen.dart';
import '../features/auth/presentation/screens/set_pin_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: PhoneNumberScreen.routePath,
        builder: (context, state) => const PhoneNumberScreen(),
      ),
      GoRoute(
        path: OtpScreen.routePath,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: SetPinScreen.routePath,
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: PinLoginScreen.routePath,
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: HomeScreen.routePath,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

