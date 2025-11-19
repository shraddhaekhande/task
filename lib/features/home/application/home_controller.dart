import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/usecases/fetch_profile_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../router/navigation_service.dart';
import '../../auth/application/auth_flow_notifier.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<UserProfile?>>((ref) {
  return HomeController(
    fetchProfileUseCase: ref.watch(fetchProfileUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    navigationService: ref.read(navigationServiceProvider),
    authFlowNotifier: ref.read(authFlowProvider.notifier),
  );
});

class HomeController extends StateNotifier<AsyncValue<UserProfile?>> {
  HomeController({
    required this.fetchProfileUseCase,
    required this.logoutUseCase,
    required this.navigationService,
    required this.authFlowNotifier,
  }) : super(const AsyncLoading()) {
    refreshProfile();
  }

  final FetchProfileUseCase fetchProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final NavigationService navigationService;
  final AuthFlowNotifier authFlowNotifier;

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchProfileUseCase());
    state.whenOrNull(
      error: (_, __) async {
        await logout();
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    authFlowNotifier.reset();
    navigationService.restartAuth();
  }
}

