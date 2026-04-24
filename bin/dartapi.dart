#!/usr/bin/env dart

import 'dart:io';
import 'package:dartapi/dartapi.dart';

void printUsage() {
  print('''
DartAPI CLI
Usage: dartapi <command>

Available commands:
  create <name> [--minimal] [--full] [--with=<features>]
      Create a new DartAPI project.
        --minimal          Bare server with one example route (default)
        --full             Full scaffold: auth, db, files, ws, metrics
        --with=<features>  Comma-separated features: auth, db, files, ws
                           e.g. --with=auth,db

  run [--port=<port>] [--env=<env>] [--watch] [--isolates=<n>]
      Run the DartAPI server.

  build [--output=<name>] [--docker]
      AOT-compile to a native binary.

  generate controller <name>   Generate a new controller
  generate resource <name>     Scaffold a full CRUD resource
  generate migration <name>    Generate a new SQL migration file

  db migrate [--dry-run]       Run pending SQL migrations
  docs [--port=<port>] [--out=<file>]  Export OpenAPI spec

Examples:
  dartapi create my_app
  dartapi create my_app --full
  dartapi create my_app --with=auth
  dartapi create my_app --with=auth,db
  dartapi run --port=8080
  dartapi run --isolates=4
  dartapi run --env=staging --watch
  dartapi build
  dartapi build --output=myapp --docker
  dartapi generate controller User
  dartapi generate resource Product
  dartapi generate migration create_users_table
  dartapi db migrate
  dartapi docs --out openapi.json
''');
}

/// Parses `--with=auth,db,files,ws` into a `Set<Feature>`.
Set<Feature> _parseWith(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--with=')) {
      final parts = arg.substring('--with='.length).split(',');
      final features = <Feature>{};
      for (final part in parts) {
        switch (part.trim().toLowerCase()) {
          case 'auth':
            features.add(Feature.auth);
          case 'db':
            features.add(Feature.db);
          case 'files':
            features.add(Feature.files);
          case 'ws':
            features.add(Feature.ws);
          default:
            print('Warning: unknown feature "$part" — ignored.');
            print('Known features: auth, db, files, ws');
        }
      }
      return features;
    }
  }
  return const {};
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('DartAPI CLI');
    print('Usage: dartapi <command>');
    print('\nRun `dartapi help` for available commands.');
    exit(0);
  }

  switch (args[0]) {
    case 'create':
      if (args.length < 2) {
        print('Please provide a project name.');
        print('Usage: dartapi create <name> [--minimal|--full|--with=<features>]');
        exit(1);
      }
      final projectName = args[1];
      final isFull = args.contains('--full');
      final features = isFull ? const <Feature>{} : _parseWith(args);
      await createProject(projectName, features: features, full: isFull);

    case 'run':
      int port = 8080;
      for (var i = 1; i < args.length; i++) {
        if (args[i].startsWith('--port=')) {
          final portStr = args[i].split('=')[1];
          port = int.tryParse(portStr) ?? -1;
          if (port < 1024 || port > 65535) {
            print('Error: Invalid port number. Use a value between 1024 and 65535.');
            exit(1);
          }
          break;
        } else if (args[i] == '--port' && i + 1 < args.length) {
          port = int.tryParse(args[i + 1]) ?? -1;
          if (port < 1024 || port > 65535) {
            print('Error: Invalid port number. Use a value between 1024 and 65535.');
            exit(1);
          }
          break;
        }
      }
      final watch = args.contains('--watch');
      String? env;
      for (final arg in args) {
        if (arg.startsWith('--env=')) {
          env = arg.split('=')[1];
          break;
        }
      }
      int isolates = 1;
      for (final arg in args) {
        if (arg.startsWith('--isolates=')) {
          isolates = int.tryParse(arg.split('=')[1]) ?? 1;
          break;
        }
      }
      runServer(port: port, watch: watch, env: env, isolates: isolates);

    case 'build':
      String buildOutput = 'server';
      bool buildDocker = false;
      for (final arg in args.skip(1)) {
        if (arg.startsWith('--output=')) {
          buildOutput = arg.split('=')[1];
        } else if (arg == '--docker') {
          buildDocker = true;
        }
      }
      await buildProject(output: buildOutput, docker: buildDocker);

    case 'generate':
      if (args.length < 3) {
        print('Please specify what to generate: controller | resource | migration');
        exit(1);
      }
      if (args[1] == 'controller') {
        await generateController(args[2]);
      } else if (args[1] == 'resource') {
        await generateResource(args[2]);
      } else if (args[1] == 'migration') {
        generateMigration(args[2]);
      } else {
        print('Unknown generate command: ${args[1]}');
      }

    case 'db':
      if (args.length < 2 || args[1] != 'migrate') {
        print('Usage: dartapi db migrate [--dry-run]');
        exit(1);
      }
      final dryRun = args.contains('--dry-run');
      await runMigrations(dryRun: dryRun);

    case 'docs':
      int docsPort = 8080;
      String? docsOutput;
      for (var i = 1; i < args.length; i++) {
        if (args[i].startsWith('--port=')) {
          docsPort = int.tryParse(args[i].split('=')[1]) ?? 8080;
        } else if (args[i] == '--port' && i + 1 < args.length) {
          docsPort = int.tryParse(args[i + 1]) ?? 8080;
        } else if (args[i].startsWith('--out=')) {
          docsOutput = args[i].split('=')[1];
        } else if (args[i] == '--out' && i + 1 < args.length) {
          docsOutput = args[i + 1];
        }
      }
      await generateDocs(port: docsPort, output: docsOutput);

    case 'help':
      printUsage();

    default:
      printUsage();
  }
}
