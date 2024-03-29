import 'package:args/command_runner.dart';

import 'src/commands/check.dart';

/// The root command runner of the `example` command.
/// To learn about it and its subcommands,
/// run `dart run example --help`.
final class ExampleCommandRunner extends CommandRunner<int> {
  ExampleCommandRunner()
      : super(
          'example',
          'Scans multiple files for text that can use YAML variables.',
        ) {
    addCommand(CheckCommand());
  }
}
