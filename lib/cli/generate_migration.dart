import 'dart:io';

/// Generates a new numbered SQL migration file in the `migrations/` directory.
///
/// Files are named `NNNN_<name>.sql`, where `NNNN` is one more than the
/// highest existing migration number (or `0001` if none exist).
///
/// ```bash
/// dartapi generate migration create_users_table
/// # creates: migrations/0001_create_users_table.sql
/// ```
void generateMigration(String name) {
  final migrationsDir = Directory('migrations');
  if (!migrationsDir.existsSync()) {
    migrationsDir.createSync();
    print('📁 Created migrations/ directory.');
  }

  final existing = migrationsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .map((f) => f.uri.pathSegments.last)
      .toList()
    ..sort();

  int nextNumber = 1;
  if (existing.isNotEmpty) {
    final last = existing.last;
    final match = RegExp(r'^(\d+)').firstMatch(last);
    if (match != null) {
      nextNumber = int.parse(match.group(1)!) + 1;
    }
  }

  final padded = nextNumber.toString().padLeft(4, '0');
  final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
  final fileName = '${padded}_$safeName.sql';
  final file = File('migrations/$fileName');

  file.writeAsStringSync(
    '-- Migration: $fileName\n'
    '-- Created by dartapi\n\n'
    '-- Write your SQL here\n',
  );

  print('✅ Created migration: migrations/$fileName');
}
