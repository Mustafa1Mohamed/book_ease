import 'dart:convert';

typedef SupabaseConfig = ({String url, String publishableKey});

SupabaseConfig parseSupabaseConfig(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('env.json must contain a JSON object.');
  }

  final url = decoded['URL'];
  final publishableKey = decoded['PUBLISHABLE_KEY'];
  if (url is! String || url.trim().isEmpty) {
    throw const FormatException('env.json is missing the URL value.');
  }
  if (publishableKey is! String || publishableKey.trim().isEmpty) {
    throw const FormatException(
      'env.json is missing the PUBLISHABLE_KEY value.',
    );
  }

  return (url: url.trim(), publishableKey: publishableKey.trim());
}
