import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  return CloudFunctionsService(functions);
});

class CloudFunctionsService {
  CloudFunctionsService(this._functions);

  final FirebaseFunctions _functions;

  Future<IssueJwtResponse> issueJwt({
    required String idToken,
  }) async {
    final callable = _functions.httpsCallable('authIssueJwt');
    final result = await callable.call({'idToken': idToken});
    return IssueJwtResponse.fromJson(_map(result.data));
  }

  Future<IssueJwtResponse> setPin({
    required String phoneNumber,
    required String pinHash,
    required String salt,
    required int iterations,
  }) async {
    final callable = _functions.httpsCallable('authSetPin');
    final result = await callable.call({
      'phoneNumber': phoneNumber,
      'pinHash': pinHash,
      'salt': salt,
      'iterations': iterations,
    });
    return IssueJwtResponse.fromJson(_map(result.data));
  }

  Future<LoginWithPinResponse> loginWithPin({
    required String phoneNumber,
    required String pinHash,
  }) async {
    final callable = _functions.httpsCallable('authLoginWithPin');
    final result = await callable.call({
      'phoneNumber': phoneNumber,
      'pinHash': pinHash,
    });
    return LoginWithPinResponse.fromJson(_map(result.data));
  }

  Future<UserProfile> fetchProfile({
    required String jwt,
  }) async {
    final callable = _functions.httpsCallable('authFetchProfile');
    final result = await callable.call({'jwt': jwt});
    return UserProfile.fromJson(_map(result.data));
  }

  Map<String, dynamic> _map(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }
}

class IssueJwtResponse {
  IssueJwtResponse({
    required this.jwt,
    required this.expiresAt,
    required this.profile,
  });

  final String jwt;
  final DateTime expiresAt;
  final UserProfile profile;

  factory IssueJwtResponse.fromJson(Map<String, dynamic> json) =>
      IssueJwtResponse(
        jwt: json['jwt'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        profile: UserProfile.fromJson(
          Map<String, dynamic>.from(json['profile'] as Map),
        ),
      );
}

class LoginWithPinResponse {
  LoginWithPinResponse({
    required this.jwt,
    required this.expiresAt,
    required this.profile,
    required this.customToken,
  });

  final String jwt;
  final DateTime expiresAt;
  final UserProfile profile;
  final String customToken;

  factory LoginWithPinResponse.fromJson(Map<String, dynamic> json) =>
      LoginWithPinResponse(
        jwt: json['jwt'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        profile: UserProfile.fromJson(
          Map<String, dynamic>.from(json['profile'] as Map),
        ),
        customToken: json['customToken'] as String,
      );
}

