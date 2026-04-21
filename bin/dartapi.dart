#!/usr/bin/env dart

import 'dart:io';
import 'package:dartapi/dartapi.dart';

void printUsage() {
  print('''
⚡ DartAPI CLI
Usage: dartapi <command>

Available commands:
  create <project_name>                        Create a new DartAPI project
  run [--port=<port>] [--env=<env>] [--watch]  Run the DartAPI server
  generate controller <name>                   Generate a new controller
  generate resource <name>                     Scaffold a full CRUD resource (controller + dto + model)
  generate migration <name>                    Generate a new SQL migration file
  db migrate [--dry-run]                       Run pending SQL migrations
  docs [--port=<port>] [--out=<file>]          Export OpenAPI spec (server must be running)

Examples:
  dartapi create my_project
  dartapi generate controller User
  dartapi generate resource Product
  dartapi generate migration create_users_table
  dartapi db migrate
  dartapi run --port=8080
  dartapi run --env=staging
  dartapi run --env=dev --watch
  dartapi docs --out openapi.json
''');
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('👀 DartAPI CLI');
    print('Usage: dartapi <command>');
    print('\nAvailable commands:');
    print('  create <project_name>  - Create a new DartAPI project');
    print('  run                    - Run the DartAPI server');
    print('  generate controller <name> - Generate a new controller');
    exit(0);
  }

  switch (args[0]) {
    case 'create':
      if (args.length < 2) {
        print('❌ Please provide a project name.');
        exit(1);
      }
      await createProject(args[1]);
      break;

    case 'run':
      int port = 8080; // Default port

      // Validate and extract the port argument
      for (var i = 1; i < args.length; i++) {
        if (args[i].startsWith('--port=')) {
          final portStr = args[i].split('=')[1];
          port = int.tryParse(portStr) ?? -1;

          if (port < 1024 || port > 65535) {
            print(
              '❌ Error: Invalid port number. Use a value between 1024 and 65535.',
            );
            exit(1);
          }
          break;
        } else if (args[i] == '--port' && i + 1 < args.length) {
          port = int.tryParse(args[i + 1]) ?? -1;

          if (port < 1024 || port > 65535) {
            print(
              '❌ Error: Invalid port number. Use a value between 1024 and 65535.',
            );
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
      runServer(port: port, watch: watch, env: env);

    case 'generate':
      if (args.length < 3) {
        print('❌ Please specify what to generate: controller | migration');
        exit(1);
      }
      if (args[1] == 'controller') {
        await generateController(args[2]);
      } else if (args[1] == 'resource') {
        await generateResource(args[2]);
      } else if (args[1] == 'migration') {
        generateMigration(args[2]);
      } else {
        print('❌ Unknown generate command: ${args[1]}');
      }
      break;

    case 'db':
      if (args.length < 2 || args[1] != 'migrate') {
        print('❌ Usage: dartapi db migrate [--dry-run]');
        exit(1);
      }
      final dryRun = args.contains('--dry-run');
      await runMigrations(dryRun: dryRun);
      break;

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
      break;

    default:
      printUsage();
  }
}
