import 'package:maat/maat.dart';
import 'package:maat_amarna/maat_amarna.dart';
import 'package:maat_seshat/maat_seshat.dart';{{ view_commands_import }}

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
  ...databaseCommands(migrations: migrations, seeders: seeders){{ view_commands }},
];
