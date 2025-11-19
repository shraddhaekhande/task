import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage.dart';

final pinStorageServiceProvider = Provider<PinStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return PinStorageService(storage);
});

class PinStorageService {
  PinStorageService(this._storage);

  final FlutterSecureStorage _storage;
  static const _pinKey = 'user_pin_secret';

  Future<void> persist(StoredPin pin) async {
    await _storage.write(
      key: _pinKey,
      value: jsonEncode(pin.toJson()),
    );
  }

  Future<StoredPin?> read() async {
    final raw = await _storage.read(key: _pinKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return StoredPin.fromJson(map);
  }

  Future<void> clear() => _storage.delete(key: _pinKey);
}

class StoredPin {
  StoredPin({
    required this.phoneNumber,
    required this.hash,
    required this.salt,
    required this.iterations,
  });

  final String phoneNumber;
  final String hash;
  final String salt;
  final int iterations;

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'hash': hash,
        'salt': salt,
        'iterations': iterations,
      };

  factory StoredPin.fromJson(Map<String, dynamic> json) => StoredPin(
        phoneNumber: json['phoneNumber'] as String,
        hash: json['hash'] as String,
        salt: json['salt'] as String,
        iterations: json['iterations'] as int,
      );
}

