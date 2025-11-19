import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFlowState {
  const AuthFlowState({
    this.phoneNumber,
    this.verificationId,
    this.requiresPinSetup = false,
    this.failedPinAttempts = 0,
  });

  final String? phoneNumber;
  final String? verificationId;
  final bool requiresPinSetup;
  final int failedPinAttempts;

  AuthFlowState copyWith({
    String? phoneNumber,
    String? verificationId,
    bool? requiresPinSetup,
    int? failedPinAttempts,
  }) {
    return AuthFlowState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      requiresPinSetup: requiresPinSetup ?? this.requiresPinSetup,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
    );
  }

  bool get hasVerificationId => verificationId != null;
}

final authFlowProvider =
    StateNotifierProvider<AuthFlowNotifier, AuthFlowState>((ref) {
  return AuthFlowNotifier();
});

class AuthFlowNotifier extends StateNotifier<AuthFlowState> {
  AuthFlowNotifier() : super(const AuthFlowState());

  void startPhoneVerification({
    required String phoneNumber,
    required String verificationId,
  }) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      verificationId: verificationId,
      failedPinAttempts: 0,
    );
  }

  void setRequiresPin(bool value) {
    state = state.copyWith(requiresPinSetup: value);
  }

  void incrementPinFailures() {
    state = state.copyWith(failedPinAttempts: state.failedPinAttempts + 1);
  }

  void resetPinFailures() {
    state = state.copyWith(failedPinAttempts: 0);
  }

  void reset() {
    state = const AuthFlowState();
  }
}

