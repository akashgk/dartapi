import 'dart:io';
import 'dart:isolate';

class TemplateEngine {
  static Future<String> render(
    String templateName,
    Map<String, String> vars,
  ) async {
    final packageUri = Uri.parse('package:dartapi/templates/$templateName');
    final resolvedUri = await Isolate.resolvePackageUri(packageUri);
    if (resolvedUri == null) {
      throw Exception('Template not found: $templateName');
    }
    final content = await File.fromUri(resolvedUri).readAsString();
    return vars.entries.fold<String>(
      content,
      (result, entry) => result.replaceAll('{{${entry.key}}}', entry.value),
    );
  }
}
