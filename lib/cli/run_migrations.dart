import 'dart:io';

/// Runs `dart run bin/migrate.dart` inside the current DartAPI project.
///
/// Expects the generated project to have a `bin/migrate.dart` entry point
/// that sets up the DB and calls [MigrationRunner.migrate()].
Future<void> runMigrations({bool dryRun = false}) async {
  final migrateScript = File('bin/migrate.dart');
  if (!migrateScript.existsSync()) {
    print(
      '❌ bin/migrate.dart not found.\n'
      '   Generate it with: dartapi generate migration <name>',
    );
    exit(1);
  }

  final args = ['run', 'bin/migrate.dart'];
  if (dryRun) args.add('--dry-run');

  print('⏳ Running migrations...');
  final result = await Process.run('dart', args);

  if (result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }
  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode != 0) {
    print('❌ Migration failed (exit code ${result.exitCode}).');
    exit(result.exitCode);
  }
}
