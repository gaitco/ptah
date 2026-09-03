import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:maat_ptah/src/new_command.dart';

const _usage = '''
Maat installer

Usage:
  maat new <name> [--force] [--api] [--maat-path=<path>] [--skip-install]
  maat <maat command>     (inside a Maat project: forwards to bin/maat.dart)
''';

Future<void> main(List<String> args) async {
  if (args.isNotEmpty && args.first == 'new') {
    final parser = ArgParser()
      ..addFlag('force', negatable: false)
      ..addFlag('api', negatable: false)
      ..addFlag('skip-install', negatable: false)
      ..addOption('maat-path');
    final results = parser.parse(args.skip(1));
    if (results.rest.isEmpty) {
      stderr.writeln(_usage);
      exit(1);
    }
    final code = await NewCommand(skeletonDir: await _skeletonDir()).run(
      results.rest.first,
      force: results['force'] as bool,
      api: results['api'] as bool,
      skipInstall: results['skip-install'] as bool,
      maatPath: results['maat-path'] as String?,
    );
    exit(code);
  }

  if (File('bin/maat.dart').existsSync()) {
    final process = await Process.start(Platform.resolvedExecutable, [
      'run',
      'bin/maat.dart',
      ...args,
    ], mode: ProcessStartMode.inheritStdio);
    exit(await process.exitCode);
  }

  stderr.writeln(_usage);
  exit(1);
}

Future<String> _skeletonDir() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:maat_ptah/skeleton/'),
  );
  if (uri == null) throw StateError('Could not locate the bundled skeleton.');
  return uri.toFilePath();
}
