import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorageService(storage);
});

class TokenStorageService {
  TokenStorageService(this._storage);

  final FlutterSecureStorage _storage;
  static const _jwtKey = 'secure_jwt';

  Future<void> persist({
    required String token,
    required DateTime expiresAt,
    required String phoneNumber,
  }) async {
    final payload = {
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'phone': phoneNumber,
    };
    await _storage.write(
      key: _jwtKey,
      value: jsonEncode(payload),
    );
  }

  Future<StoredToken?> read() async {
    final raw = await _storage.read(key: _jwtKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StoredToken(
      token: decoded['token'] as String,
      expiresAt: DateTime.tryParse(decoded['expiresAt'] as String? ?? ''),
      phoneNumber: decoded['phone'] as String?,
    );
  }

  Future<bool> hasValidToken() async {
    final stored = await read();
    if (stored == null || stored.expiresAt == null) {
      return false;
    }
    return stored.expiresAt!.isAfter(DateTime.now());
  }

  Future<void> clear() => _storage.delete(key: _jwtKey);
}

class StoredToken {
  StoredToken({
    required this.token,
    required this.expiresAt,
    required this.phoneNumber,
  });

  final String token;
  final DateTime? expiresAt;
  final String? phoneNumber;
}

