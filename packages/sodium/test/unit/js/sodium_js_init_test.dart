@TestOn('js')
library sodium_js_init_test;

import 'dart:js_interop';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:sodium/src/js/sodium_js_init.dart';
import 'package:test/test.dart';

@JSExport()
class MockLibSodiumJS extends Mock {}

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  test('initFromSodiumJS returns SodiumJS instance', () async {
    final sodium = await SodiumInit.initFromSodiumJS2(() => mockSodium);

    expect(
      sodium,
      isA<SodiumJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('init returns SodiumJS instance', () async {
    final sodium = await SodiumInit.init2(() => mockSodium);

    expect(
      sodium,
      isA<SodiumJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
