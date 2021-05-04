import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/push/init_push_result.dart';
import '../../../../api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'secret_stream_message_tag_jsx.dart';

@internal
class SecretStreamPushTransformerSinkJS
    extends SecretStreamPushTransformerSink<num> {
  final LibSodiumJS sodium;

  SecretStreamPushTransformerSinkJS(this.sodium);

  @override
  InitPushResult<num> initialize(SecureKey key) {
    final initResult = JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretstream_xchacha20poly1305_init_push(
          keyData,
        ),
      ),
    );

    return InitPushResult(
      header: initResult.header,
      state: initResult.state,
    );
  }

  @override
  void rekey(num cryptoState) => JsError.wrap(
        // always returns true, ignore result
        () => sodium.crypto_secretstream_xchacha20poly1305_rekey(cryptoState),
      );

  @override
  SecretStreamCipherMessage encryptMessage(
    num cryptoState,
    SecretStreamPlainMessage event,
  ) {
    final cipherText = JsError.wrap(
      () => sodium.crypto_secretstream_xchacha20poly1305_push(
        cryptoState,
        event.message,
        event.additionalData,
        event.tag.getValue(sodium),
      ),
    );

    return SecretStreamCipherMessage(
      cipherText,
      additionalData: event.additionalData,
    );
  }

  @override
  void disposeState(num cryptoState) {}
}

@internal
class SecretStreamPushTransformerJS extends SecretStreamPushTransformer<num> {
  final LibSodiumJS sodium;

  const SecretStreamPushTransformerJS(this.sodium, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<num> createSink() =>
      SecretStreamPushTransformerSinkJS(sodium);
}
