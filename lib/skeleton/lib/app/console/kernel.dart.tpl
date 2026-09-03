import 'package:maat/maat.dart';
import 'package:amarna/amarna.dart';
import 'package:seshat_maat/seshat_maat.dart';{{ view_commands_import }}
import 'package:sistrum/sistrum.dart';
import 'package:thoth_realtime/thoth_realtime.dart';

/// Application console commands. `make:command` creates classes under
/// commands/; add an instance to the returned list to register it.
///
/// The registries are parameters rather than imports because a file under
/// `lib/` cannot relative-import `database/migrations.dart` — Dart forbids
/// escaping the package's `lib/` root. `bin/maat.dart` lives outside
/// `lib/`, so it reads them and passes them in.
List<Command> commands({
  required List<Migration> migrations,
  required List<Seeder> seeders,
}) => [
  MakeMailCommand(),
  MakeNotificationCommand(),
  ThothStartCommand(),
  ThothPingCommand(),
  ...databaseCommands(migrations: migrations, seeders: seeders){{ view_commands }},
];
