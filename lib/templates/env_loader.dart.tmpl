import 'dart:io';

/// Parses a `.env` file into a [Map<String, String>].
///
/// Rules:
/// - Lines beginning with `#` are comments and are ignored.
/// - Empty lines are ignored.
/// - Values may be quoted with `"` or `'` — quotes are stripped.
/// - Inline comments (`key=value # comment`) are stripped.
/// - Returns an empty map if the file does not exist.
Map<String, String> loadEnvFile(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};

  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final eqIndex = trimmed.indexOf('=');
    if (eqIndex < 0) continue;

    final key = trimmed.substring(0, eqIndex).trim();
    var value = trimmed.substring(eqIndex + 1).trim();

    // Strip inline comment (space + #)
    final commentIdx = value.indexOf(' #');
    if (commentIdx >= 0) value = value.substring(0, commentIdx).trim();

    // Strip surrounding quotes
    if (value.length >= 2) {
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
    }

    if (key.isNotEmpty) result[key] = value;
  }
  return result;
}

/// Merges env maps in order — later maps override earlier ones.
/// [Platform.environment] is always applied last so real process
/// environment variables always take the highest priority.
Map<String, String> mergeEnv(List<Map<String, String>> sources) {
  final merged = <String, String>{};
  for (final source in sources) {
    merged.addAll(source);
  }
  merged.addAll(Platform.environment);
  return merged;
}
