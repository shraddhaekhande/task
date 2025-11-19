import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

class CryptoService {
  static const _iterations = 12000;

  String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String hashPin({
    required String pin,
    required String salt,
    int iterations = _iterations,
  }) {
    List<int> hashBytes = utf8.encode('$pin$salt');
    final key = utf8.encode(salt);
    final hmac = Hmac(sha256, key);
    for (var i = 0; i < iterations; i++) {
      hashBytes = hmac.convert(hashBytes).bytes;
    }
    return base64Url.encode(hashBytes);
  }

  int get defaultIterations => _iterations;
}

