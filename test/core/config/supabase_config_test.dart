import 'package:book_ease/core/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and trims the Supabase settings', () {
    final config = parseSupabaseConfig(
      '{"URL":" https://example.supabase.co ",'
      '"PUBLISHABLE_KEY":" test-publishable-key "}',
    );

    expect(config.url, 'https://example.supabase.co');
    expect(config.publishableKey, 'test-publishable-key');
  });

  test('rejects missing Supabase settings', () {
    expect(
      () => parseSupabaseConfig('{"URL":"https://example.supabase.co"}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a non-object config', () {
    expect(() => parseSupabaseConfig('[]'), throwsA(isA<FormatException>()));
  });
}
