class PinMismatchException implements Exception {
  PinMismatchException([this.message = 'Incorrect PIN']);

  final String message;

  @override
  String toString() => message;
}

class MissingPinException implements Exception {
  MissingPinException(
    [this.message = 'PIN login unavailable on this device. Please use OTP.']);

  final String message;

  @override
  String toString() => message;
}

