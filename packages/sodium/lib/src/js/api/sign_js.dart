// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sign.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import 'helpers/sign/signature_consumer_js.dart';
import 'helpers/sign/verification_consumer_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class SignJS with SignValidations implements Sign {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SignJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_sign_PUBLICKEYBYTES;

  @override
  int get secretKeyBytes => sodium.crypto_sign_SECRETKEYBYTES;

  @override
  int get bytes => sodium.crypto_sign_BYTES;

  @override
  int get seedBytes => sodium.crypto_sign_SEEDBYTES;

  @override
  KeyPair keyPair() {
    final keyPair = jsErrorWrap(() => sodium.crypto_sign_keypair());

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = jsErrorWrap(
      () => seed.runUnlockedSync(
        (seedData) => sodium.crypto_sign_seed_keypair(seedData.toJS),
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium
            .crypto_sign(
              message.toJS,
              secretKeyData.toJS,
            )
            .toDart,
      ),
    );
  }

  @override
  Uint8List open({
    required Uint8List signedMessage,
    required Uint8List publicKey,
  }) {
    validateSignedMessage(signedMessage);
    validatePublicKey(publicKey);

    return jsErrorWrap(
      () => sodium
          .crypto_sign_open(
            signedMessage.toJS,
            publicKey.toJS,
          )
          .toDart,
    );
  }

  @override
  Uint8List detached({
    required Uint8List message,
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium
            .crypto_sign_detached(
              message.toJS,
              secretKeyData.toJS,
            )
            .toDart,
      ),
    );
  }

  @override
  bool verifyDetached({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    return jsErrorWrap(
      () => sodium.crypto_sign_verify_detached(
        signature.toJS,
        message.toJS,
        publicKey.toJS,
      ),
    );
  }

  @override
  SignatureConsumer createConsumer({
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return SignatureConsumerJS(
      sodium: sodium,
      secretKey: secretKey,
    );
  }

  @override
  VerificationConsumer createVerifyConsumer({
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    return VerificationConsumerJS(
      sodium: sodium,
      signature: signature,
      publicKey: publicKey,
    );
  }
}
