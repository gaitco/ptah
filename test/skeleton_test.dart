import 'dart:io';

import 'package:khnum/khnum.dart';
import 'package:ptah/src/skeleton_copier.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final skeleton = p.join(Directory.current.path, 'lib', 'skeleton');
  final frameworkPath = p.normalize(
    p.join(Directory.current.path, '..', 'maat'),
  );
  final databasePath = p.normalize(
    p.join(Directory.current.path, '..', 'seshat_maat'),
  );
  final databaseCorePath = p.normalize(
    p.join(Directory.current.path, '..', 'seshat'),
  );
  final viewPath = p.normalize(
    p.join(Directory.current.path, '..', 'khnum_maat'),
  );
  final viewCorePath = p.normalize(
    p.join(Directory.current.path, '..', 'khnum'),
  );
  final mailPath = p.normalize(p.join(Directory.current.path, '..', 'amarna'));
  final notificationPath = p.normalize(
    p.join(Directory.current.path, '..', 'sistrum'),
  );
  final thothPath = p.normalize(p.join(Directory.current.path, '..', 'thoth'));
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('skeleton'));
  tearDown(() => dir.deleteSync(recursive: true));

  // Every key NewCommand supplies, so a `copyTo` call here never leaves a
  // skeleton file with an unfilled `{{ ... }}` token.
  Map<String, String> replacements({String dependencyOverrides = ''}) => {
    'name': 'blog',
    'maat_dependency': '^0.1.1',
    'seshat_maat_dependency': '^0.1.0',
    'amarna_dependency': '^0.1.0',
    'sistrum_dependency': '^0.1.0',
    'thoth_dependency': '^0.1.0',
    'view_dependency': '\n  khnum_maat: ^0.1.0',
    'dependency_overrides': dependencyOverrides,
    'view_provider': '\n          ViewServiceProvider.new,',
    'view_commands': ', ...viewCommands()',
    'view_config_import': "\nimport 'view.dart';",
    'view_config_entry': "\n  'view': view,",
    'view_import': "\nimport 'package:khnum_maat/khnum_maat.dart';",
    'view_commands_import': "\nimport 'package:khnum_maat/khnum_maat.dart';",
    'web_routes_body':
        "  Route.get('/', (Request request) => view('welcome'));\n"
        "  Route.get('/dashboard', (Request request) => view('dashboard'));",
  };

  test('targetRelativePath renames dot files and strips .tpl', () {
    expect(
      SkeletonCopier.targetRelativePath('dot.env.example'),
      '.env.example',
    );
    expect(
      SkeletonCopier.targetRelativePath('pubspec.yaml.tpl'),
      'pubspec.yaml',
    );
    expect(
      SkeletonCopier.targetRelativePath(
        p.join('storage', 'logs', 'dot.gitkeep'),
      ),
      p.join('storage', 'logs', '.gitkeep'),
    );
    expect(
      SkeletonCopier.targetRelativePath(
        p.join('database', 'migrations', 'dot.gitkeep'),
      ),
      p.join('database', 'migrations', '.gitkeep'),
    );
    expect(
      SkeletonCopier.targetRelativePath(p.join('bin', 'server.dart.tpl')),
      p.join('bin', 'server.dart'),
    );
  });

  test('copies, renames and replaces placeholders', () async {
    final written = await SkeletonCopier(
      skeleton,
    ).copyTo(dir.path, replacements());
    expect(
      written,
      containsAll([
        'pubspec.yaml',
        '.env.example',
        '.gitignore',
        p.join('bin', 'maat.dart'),
      ]),
    );
    expect(
      File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
      contains('name: blog'),
    );
    expect(
      File(p.join(dir.path, 'bin', 'maat.dart')).readAsStringSync(),
      contains("package:blog/app/console/kernel.dart"),
    );
    expect(
      File(p.join(dir.path, '.env.example')).readAsStringSync(),
      contains('APP_NAME=blog'),
    );
    expect(
      File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
      contains('seshat_maat: ^0.1.0'),
    );
    expect(
      File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
      contains('amarna: ^0.1.0'),
    );
    expect(
      File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
      contains('sistrum: ^0.1.0'),
    );
    expect(
      File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
      contains('thoth_realtime: ^0.1.0'),
    );
    final databaseConfig = File(
      p.join(dir.path, 'config', 'database.dart'),
    ).readAsStringSync();
    expect(
      databaseConfig,
      contains("'default': env('DB_CONNECTION', 'sqlite')"),
    );
    expect(databaseConfig, contains("'sqlite': {"));
    expect(databaseConfig, contains("'pgsql': {"));
    expect(databaseConfig, contains("'mysql': {"));
    expect(
      File(p.join(dir.path, 'config', 'config.dart')).readAsStringSync(),
      contains("'database': database"),
    );
    final mailConfig = File(
      p.join(dir.path, 'config', 'mail.dart'),
    ).readAsStringSync();
    expect(mailConfig, contains("'default': env('MAIL_MAILER', 'log')"));
    expect(mailConfig, contains("'transport': 'smtp'"));
    expect(
      File(p.join(dir.path, 'config', 'config.dart')).readAsStringSync(),
      contains("'mail': mail"),
    );
    final bootstrap = File(
      p.join(dir.path, 'bootstrap', 'app.dart'),
    ).readAsStringSync();
    expect(bootstrap, contains('DatabaseServiceProvider.new'));
    expect(bootstrap, contains('MailServiceProvider.new'));
    expect(bootstrap, contains('NotificationServiceProvider.new'));
    expect(bootstrap, contains('BroadcastServiceProvider.new'));
    expect(bootstrap, contains('ThothServiceProvider.new'));
    expect(
      bootstrap.indexOf('MailServiceProvider.new'),
      greaterThan(bootstrap.indexOf('ViewServiceProvider.new')),
    );
    expect(
      bootstrap.indexOf('MailServiceProvider.new'),
      lessThan(bootstrap.indexOf('RouteServiceProvider')),
    );
    expect(
      bootstrap.indexOf('NotificationServiceProvider.new'),
      greaterThan(bootstrap.indexOf('MailServiceProvider.new')),
    );
    expect(
      bootstrap.indexOf('NotificationServiceProvider.new'),
      lessThan(bootstrap.indexOf('RouteServiceProvider')),
    );
    expect(
      File(p.join(dir.path, 'database', 'migrations.dart')).readAsStringSync(),
      contains('final migrations = <Migration>['),
    );
    expect(
      File(
        p.join(dir.path, 'database', 'seeders', 'database_seeder.dart'),
      ).readAsStringSync(),
      contains('final seeders = <Seeder>['),
    );
    expect(
      Directory(p.join(dir.path, 'database', 'migrations')).existsSync(),
      isTrue,
    );
    final kernel = File(
      p.join(dir.path, 'lib', 'app', 'console', 'kernel.dart'),
    ).readAsStringSync();
    expect(
      kernel,
      contains('databaseCommands(migrations: migrations, seeders: seeders)'),
    );
    expect(kernel, contains('MakeMailCommand()'));
    expect(kernel, contains('MakeNotificationCommand()'));
    expect(kernel, contains('ThothStartCommand()'));
    expect(kernel, contains('ThothPingCommand()'));
    final migrations = File(
      p.join(dir.path, 'database', 'migrations.dart'),
    ).readAsStringSync();
    expect(migrations, contains('...sistrumMigrations'));
    final environment = File(
      p.join(dir.path, '.env.example'),
    ).readAsStringSync();
    expect(environment, contains('DB_CONNECTION=sqlite'));
    for (final key in [
      'MAIL_MAILER',
      'MAIL_HOST',
      'MAIL_PORT',
      'MAIL_USERNAME',
      'MAIL_PASSWORD',
      'MAIL_ENCRYPTION',
      'MAIL_FROM_ADDRESS',
      'MAIL_FROM_NAME',
      'BROADCAST_CONNECTION',
      'PUSHER_APP_ID',
      'PUSHER_APP_KEY',
      'PUSHER_APP_SECRET',
      'PUSHER_HOST',
      'PUSHER_PORT',
      'PUSHER_SCHEME',
      'THOTH_HOST',
      'THOTH_PORT',
    ]) {
      expect(environment, contains('$key='));
    }
    expect(
      Directory(p.join(dir.path, 'lib', 'skeleton')).existsSync(),
      isFalse,
    );
    // Every placeholder in `replacements()` above must actually be filled —
    // an unfilled `{{ ... }}` is not valid Dart/YAML, so a gap here would
    // silently corrupt the generated project.
    for (final relative in [
      'pubspec.yaml',
      p.join('bootstrap', 'app.dart'),
      p.join('config', 'config.dart'),
      p.join('lib', 'app', 'console', 'kernel.dart'),
      p.join('routes', 'web.dart'),
    ]) {
      expect(
        File(p.join(dir.path, relative)).readAsStringSync(),
        isNot(contains('{{')),
        reason: '$relative has an unfilled placeholder',
      );
    }
  });

  test(
    '.khnum.html files are copied verbatim, so their {{ }} props survive',
    () async {
      await SkeletonCopier(skeleton).copyTo(dir.path, replacements());
      final inputComponent = File(
        p.join(
          dir.path,
          'resources',
          'views',
          'components',
          'input.khnum.html',
        ),
      ).readAsStringSync();
      // The replacements map's 'name' key (the project name, 'blog') must
      // not have been substituted into the component's own `{{ name }}`
      // prop — that is Khnum's expression syntax, not a placeholder.
      expect(inputComponent, contains('{{ name }}'));
      expect(inputComponent, isNot(contains('"blog"')));

      // Render the generated project's own component to prove the prop
      // still resolves from the caller's argument, not the project name.
      File(
        p.join(dir.path, 'resources', 'views', 'probe.khnum.html'),
      ).writeAsStringSync('<x-input name="email" />');
      final khnum = Khnum(viewsPath: p.join(dir.path, 'resources', 'views'));
      final rendered = await khnum.render('probe');
      expect(rendered, contains('name="email"'));
      expect(rendered, isNot(contains('name="blog"')));
      expect(rendered, isNot(contains('id="blog"')));
    },
  );

  test('skip omits matching files', () async {
    final written = await SkeletonCopier(skeleton).copyTo(
      dir.path,
      replacements(),
      skip: (relative) => relative.startsWith('config'),
    );
    expect(written.any((f) => f.startsWith('config')), isFalse);
    expect(written, contains(p.join('bin', 'server.dart')));
  });

  test(
    'skeleton compiles, analyzes and its test passes against the local framework',
    () async {
      await SkeletonCopier(skeleton).copyTo(
        dir.path,
        replacements(
          dependencyOverrides:
              '''
dependency_overrides:
  maat:
    path: $frameworkPath
  seshat_maat:
    path: $databasePath
  seshat:
    path: $databaseCorePath
  khnum_maat:
    path: $viewPath
  khnum:
    path: $viewCorePath
  amarna:
    path: $mailPath
  sistrum:
    path: $notificationPath
  thoth_realtime:
    path: $thothPath
''',
        ),
      );
      File(p.join(dir.path, '.env.example')).copySync(p.join(dir.path, '.env'));
      Future<void> run(List<String> args) async {
        final r = await Process.run('dart', args, workingDirectory: dir.path);
        expect(
          r.exitCode,
          0,
          reason: 'dart ${args.join(' ')}\n${r.stdout}\n${r.stderr}',
        );
      }

      await run(['pub', 'get']);
      await run(['analyze', '--fatal-infos']);
      await run(['test']);
      await run(['run', 'bin/maat.dart', 'route:list']);
      await run([
        'run',
        'bin/maat.dart',
        'make:migration',
        'create_posts_table',
        '--create=posts',
      ]);
      await run(['run', 'bin/maat.dart', 'migrate']);
      await run(['analyze', '--fatal-infos']);
      expect(
        File(p.join(dir.path, 'database', 'database.sqlite')).existsSync(),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
