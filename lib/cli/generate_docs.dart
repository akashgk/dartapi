import 'dart:convert';
import 'dart:io';

/// Fetches the OpenAPI spec from a running DartAPI server and writes it to
/// [output] (or prints to stdout if [output] is null).
///
/// Requires the server to be running (`dartapi run`) before calling this.
Future<void> generateDocs({int port = 8080, String? output}) async {
  final url = Uri.parse('http://localhost:$port/openapi.json');

  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();

    if (response.statusCode != 200) {
      print('❌ Server returned ${response.statusCode}. Is the server running?');
      exit(1);
    }

    final body = await response.transform(utf8.decoder).join();

    // Pretty-print if already valid JSON.
    final pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(body));

    if (output != null) {
      File(output).writeAsStringSync(pretty);
      print('✅ OpenAPI spec saved to $output');
    } else {
      print(pretty);
    }

    client.close();
  } on SocketException {
    print(
      '❌ Could not connect to http://localhost:$port. '
      'Make sure the server is running with `dartapi run --port=$port`.',
    );
    exit(1);
  }
}
