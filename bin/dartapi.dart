#!/usr/bin/env dart

import 'dart:io';
import 'cli/create_project.dart';
import 'cli/run_server.dart';
import 'cli/generate_controllers.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('⚡ DartAPI CLI');
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
      createProject(args[1]);
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
        }
      }

      runServer(port: port);

    case 'generate':
      if (args.length < 3) {
        print('❌ Please specify what to generate (controller) and name.');
        exit(1);
      }
      if (args[1] == 'controller') {
        generateController(args[2]);
      } else {
        print('❌ Unknown generate command.');
      }
      break;

    default:
      print('❌ Unknown command.');
  }
}
