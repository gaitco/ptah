import 'dart:io';

import 'package:maat_ptah/src/new_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final skeleton = p.join(Directory.current.path, 'lib', 'skeleton');
  late Directory dir;
  late StringBuffer out;
  late StringBuffer err;
  late List<List<String>> processes;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('new');
    out = StringBuffer();
    err = StringBuffer();
    processes = [];
  });
  tearDown(() => dir.deleteSync(recursive: true));

  NewCommand command() => NewCommand(
    skeletonDir: skeleton,
    out: out,
    err: err,
    runProcess: (exe, args, cwd) async {
      processes.add([exe, ...args, cwd]);
      return ProcessResult(0, 0, '', '');
    },
  );

  test(
    'creates the project, .env, and runs pub get and key:generate',
    () async {
      expect(await command().run('blog', parentDir: dir.path), 0);
      final root = p.join(dir.path, 'blog');
      final pubspec = File(p.join(root, 'pubspec.yaml')).readAsStringSync();
      expect(pubspec, contains('maat: ^0.1.0'));
      expect(pubspec, contains('maat_seshat: ^0.1.0'));
      expect(pubspec, contains('maat_amarna: ^0.1.0'));
      // Guards every placeholder, not just today's two: an unfilled `{{ ... }}`
      // is not valid YAML, so `pub get` fails in the generated project.
      expect(pubspec, isNot(contains('{{')));
      expect(File(p.join(root, '.env')).existsSync(), isTrue);
      expect(File(p.join(root, '.gitignore')).existsSync(), isTrue);
      expect(processes, [
        ['dart', 'pub', 'get', root],
        ['dart', 'run', 'bin/maat.dart', 'key:generate', root],
      ]);
      expect(out.toString(), contains('cd blog'));
      expect(out.toString(), contains('maat serve'));
    },
  );

  test('maatPath writes local overrides; skipInstall runs nothing', () async {
    await command().run(
      'blog',
      parentDir: dir.path,
      maatPath: '/tmp/fw',
      skipInstall: true,
    );
    final pubspec = File(
      p.join(dir.path, 'blog', 'pubspec.yaml'),
    ).readAsStringSync();
    expect(pubspec, contains('maat: ^0.1.0'));
    expect(pubspec, contains('dependency_overrides:'));
    expect(pubspec, contains('path: /tmp/fw'));
    expect(pubspec, contains('path: ${p.join('/tmp', 'maat_amarna')}'));
    expect(
      pubspec,
      contains('path: ${p.join('/tmp', 'maat_seshat_core')}\n  maat_khnum:'),
    );
    expect(pubspec, isNot(contains('{{')));
    expect(processes, isEmpty);
  });

  test('rejects invalid names and existing directories', () async {
    expect(await command().run('Blog', parentDir: dir.path), 1);
    expect(err.toString(), contains('valid Dart package name'));
    Directory(p.join(dir.path, 'taken')).createSync();
    File(p.join(dir.path, 'taken', 'x')).writeAsStringSync('');
    expect(await command().run('taken', parentDir: dir.path), 1);
    expect(err.toString(), contains('already exists'));
    expect(
      await command().run(
        'taken',
        parentDir: dir.path,
        force: true,
        skipInstall: true,
      ),
      0,
    );
  });

  test('reports failing subprocesses', () async {
    final failing = NewCommand(
      skeletonDir: skeleton,
      out: out,
      err: err,
      runProcess: (exe, args, cwd) async => ProcessResult(0, 66, '', 'boom'),
    );
    expect(await failing.run('blog', parentDir: dir.path), 66);
    expect(err.toString(), contains('boom'));
  });

  test('--api omits the frontend and its wiring', () async {
    await command().run(
      'apiapp',
      parentDir: dir.path,
      api: true,
      skipInstall: true,
    );
    final root = p.join(dir.path, 'apiapp');
    expect(Directory(p.join(root, 'resources')).existsSync(), isFalse);
    expect(Directory(p.join(root, 'public')).existsSync(), isFalse);
    // Target-relative: proves the skip predicate matches after
    // dot.gitkeep is renamed to .gitkeep, not before.
    expect(
      File(p.join(root, 'public', 'css', '.gitkeep')).existsSync(),
      isFalse,
    );
    final pubspec = File(p.join(root, 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, isNot(contains('maat_khnum')));
    expect(pubspec, contains('maat_amarna'));
    final bootstrap = File(
      p.join(root, 'bootstrap', 'app.dart'),
    ).readAsStringSync();
    expect(bootstrap, isNot(contains('ViewServiceProvider')));
    expect(bootstrap, contains('MailServiceProvider.new'));
    final config = File(
      p.join(root, 'config', 'config.dart'),
    ).readAsStringSync();
    expect(config, isNot(contains("'view'")));
    for (final file in [
      'pubspec.yaml',
      'bootstrap/app.dart',
      'config/config.dart',
    ]) {
      expect(
        File(p.join(root, file)).readAsStringSync(),
        isNot(contains('{{')),
        reason: '$file has an unfilled placeholder',
      );
    }
  });

  test('the full edition ships the frontend and its wiring', () async {
    await command().run('webapp', parentDir: dir.path, skipInstall: true);
    final root = p.join(dir.path, 'webapp');
    expect(
      File(p.join(root, 'resources', 'css', 'app.css')).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(root, 'resources', 'views', 'layouts', 'app.khnum.html'),
      ).existsSync(),
      isTrue,
    );
    // Target-relative: public/css/ exists before the first `maat
    // tailwind` run, so createStaticHandler has a document root.
    expect(
      File(p.join(root, 'public', 'css', '.gitkeep')).existsSync(),
      isTrue,
    );
    final pubspec = File(p.join(root, 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, contains('maat_khnum'));
    final bootstrap = File(
      p.join(root, 'bootstrap', 'app.dart'),
    ).readAsStringSync();
    expect(bootstrap, contains('ViewServiceProvider.new'));
    for (final file in [
      'pubspec.yaml',
      'bootstrap/app.dart',
      'config/config.dart',
      'routes/web.dart',
    ]) {
      expect(
        File(p.join(root, file)).readAsStringSync(),
        isNot(contains('{{')),
      );
    }
  });

  test('web routes render views rather than inline HTML', () async {
    await command().run('webroutes', parentDir: dir.path, skipInstall: true);
    final routes = File(
      p.join(dir.path, 'webroutes', 'routes', 'web.dart'),
    ).readAsStringSync();
    expect(routes, contains("view('welcome')"));
    expect(routes, contains("view('dashboard')"));
    expect(routes, isNot(contains('<h1>Maat</h1>')));
  });

  test('both editions register PublicFiles ahead of the router', () async {
    for (final edition in [true, false]) {
      final name = edition ? 'apimw' : 'webmw';
      await command().run(
        name,
        parentDir: dir.path,
        api: edition,
        skipInstall: true,
      );
      final bootstrap = File(
        p.join(dir.path, name, 'bootstrap', 'app.dart'),
      ).readAsStringSync();
      expect(
        bootstrap,
        contains('PublicFiles(publicPath())'),
        reason: '$name does not serve public/',
      );
    }
  });
}
