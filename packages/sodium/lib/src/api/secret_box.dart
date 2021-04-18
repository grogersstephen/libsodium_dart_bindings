import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/src/api/secure_key.dart';

part 'secret_box.freezed.dart';

@freezed
class DetachedSecretBoxResult with _$DetachedSecretBoxResult {
  const factory DetachedSecretBoxResult({
    required Uint8List cipher,
    required Uint8List mac,
  }) = _DetachedSecretBoxResult;
}

abstract class SecretBox {
  const SecretBox._(); // coverage:ignore-line

  int get keyBytes;
  int get macBytes;
  int get nonceBytes;

  // crypto_secretbox_primitive

  SecureKey keygen();

  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  });

  Uint8List openEasy({
    required Uint8List ciphertext,
    required Uint8List nonce,
    required SecureKey key,
  });

  DetachedSecretBoxResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  });

  Uint8List openDetached({
    required Uint8List ciphertext,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
  });
}

@internal
mixin SecretBoxValidations implements SecretBox {
  void validateNonce(Uint8List nonce) => RangeError.checkValueInInterval(
        nonce.length,
        nonceBytes,
        nonceBytes,
        'nonce',
      );

  void validateKey(SecureKey key) => RangeError.checkValueInInterval(
        key.length,
        keyBytes,
        keyBytes,
        'key',
      );

  void validateMac(Uint8List mac) => RangeError.checkValueInInterval(
        mac.length,
        macBytes,
        macBytes,
        'mac',
      );
}