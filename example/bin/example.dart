import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/io.dart' as io;

import 'package:example/example.dart';

Future<void> main(List<String> args) async {
  final runner = ExampleCommandRunner();
  try {
    final result =
        await runner.run(args).whenComplete(io.sharedStdIn.terminate);

    exit(result is int ? result : 0);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  } catch (e, stackTrace) {
    stderr.writeln(e);
    stderr.writeln(stackTrace);
    exit(1);
  }
}
