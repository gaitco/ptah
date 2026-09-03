import 'dart:io';

import 'package:path/path.dart' as p;

import 'skeleton_copier.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> args,
      String workingDirectory,
    );

/// `maat new <name>`: copy the skeleton, create .env, install, generate the key.
class NewCommand {
  NewCommand({
    required this.skeletonDir,
    StringSink? out,
    StringSink? err,
    ProcessRunner? runProcess,
  }) : _out = out ?? stdout,
       _err = err ?? stderr,
       _run =
           runProcess ??
           ((exe, args, cwd) => Process.run(exe, args, workingDirectory: cwd));

  final String skeletonDir;
  final StringSink _out;
  final StringSink _err;
  final ProcessRunner _run;

  static final _validName = RegExp(r'^[a-z][a-z0-9_]*$');

  /// Skeleton paths that exist only in the full edition. `--api` is Lumen-
  /// shaped: no views, no CSS, no document root.
  static const List<String> frontendPaths = ['resources', 'public'];

  Future<int> run(
    String name, {
    String? parentDir,
    bool force = false,
    String? maatPath,
    bool api = false,
    bool skipInstall = false,
  }) async {
    if (!_validName.hasMatch(name)) {
      _err.writeln(
        '"$name" is not a valid Dart package name (lowercase letters, digits, underscores).',
      );
      return 1;
    }
    final root = p.join(parentDir ?? Directory.current.path, name);
    final target = Directory(root);
    if (target.existsSync() && target.listSync().isNotEmpty && !force) {
      _err.writeln(
        'Directory [$root] already exists and is not empty. Use --force to overwrite.',
      );
      return 1;
    }

    _out.writeln('Creating a Maat application in $root ...');
    final packagesPath = maatPath == null ? null : p.dirname(maatPath);
    final dependencyOverrides = packagesPath == null
        ? ''
        : '''
dependency_overrides:
  maat:
    path: $maatPath
  seshat_maat:
    path: ${p.join(packagesPath, 'seshat_maat')}
  seshat:
    path: ${p.join(packagesPath, 'seshat')}
${api ? '' : '''  khnum_maat:
    path: ${p.join(packagesPath, 'khnum_maat')}
  khnum:
    path: ${p.join(packagesPath, 'khnum')}'''}
  amarna:
    path: ${p.join(packagesPath, 'amarna')}
  sistrum:
    path: ${p.join(packagesPath, 'sistrum')}
  thoth_realtime:
    path: ${p.join(packagesPath, 'thoth')}
''';
    await SkeletonCopier(skeletonDir).copyTo(
      root,
      {
        'name': name,
        'maat_dependency': '^0.1.1',
        'seshat_maat_dependency': '^0.1.0',
        'amarna_dependency': '^0.1.0',
        'sistrum_dependency': '^0.1.0',
        'thoth_dependency': '^0.1.0',
        'view_dependency': api ? '' : '\n  khnum_maat: ^0.1.0',
        'dependency_overrides': dependencyOverrides,
        'view_provider': api ? '' : '\n          ViewServiceProvider.new,',
        'view_commands': api ? '' : ', ...viewCommands()',
        'view_config_import': api ? '' : "\nimport 'view.dart';",
        'view_config_entry': api ? '' : "\n  'view': view,",
        'view_import': api
            ? ''
            : "\nimport 'package:khnum_maat/khnum_maat.dart';",
        'view_commands_import': api
            ? ''
            : "\nimport 'package:khnum_maat/khnum_maat.dart';",
        'web_routes_body': api
            ? "  Route.get('/', (Request request) => {'framework': 'Maat'});"
            : "  Route.get('/', (Request request) => view('welcome'));\n"
                  "  Route.get('/dashboard', (Request request) => view('dashboard'));",
      },
      skip: api
          ? (relative) =>
                relative == p.join('config', 'view.dart') ||
                frontendPaths.any(
                  (prefix) =>
                      relative == prefix ||
                      relative.startsWith('$prefix${p.separator}'),
                )
          : null,
    );
    File(p.join(root, '.env.example')).copySync(p.join(root, '.env'));

    if (!skipInstall) {
      for (final args in [
        ['pub', 'get'],
        ['run', 'bin/maat.dart', 'key:generate'],
      ]) {
        _out.writeln('> dart ${args.join(' ')}');
        final result = await _run('dart', args, root);
        if (result.exitCode != 0) {
          _err.writeln(
            'dart ${args.join(' ')} failed (${result.exitCode}):\n${result.stdout}${result.stderr}',
          );
          return result.exitCode;
        }
      }
    }

    _out.writeln(
      '\nApplication ready. Next steps:\n  cd $name\n  maat serve\n',
    );
    return 0;
  }
}
