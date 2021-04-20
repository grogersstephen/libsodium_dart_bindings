import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/pwhash_ffi.dart';
import 'package:sodium/src/ffi/api/secret_box_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late CryptoFFI sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoFFI(mockSodium);
  });

  test('secretBox returns SecretBoxFFI instance', () {
    expect(
      sut.secretBox,
      isA<SecretBoxFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('pwhash returns PwhashFFI instance', () {
    expect(
      sut.pwhash,
      isA<PwhashFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
