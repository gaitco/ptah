import 'dart:io';

Future<void> main() async {
  final executable = File('bin/maat.dart').absolute;
  final parent = Directory.systemTemp.createTempSync('ptah_example');

  try {
    final result = await Process.run(Platform.resolvedExecutable, [
      executable.path,
      'new',
      'hello',
      '--skip-install',
    ], workingDirectory: parent.path);
    if (result.exitCode != 0) {
      throw ProcessException(
        executable.path,
        const ['new', 'hello', '--skip-install'],
        '${result.stdout}${result.stderr}',
        result.exitCode,
      );
    }
    stdout.write(result.stdout);
  } finally {
    parent.deleteSync(recursive: true);
  }
}
