import 'dart:io';

import 'package:maat/maat.dart';
import 'package:{{ name }}/app/console/kernel.dart';

import '../bootstrap/app.dart';
import '../database/migrations.dart';
import '../database/seeders/database_seeder.dart';

Future<void> main(List<String> args) async {
  final application = await createApp();
  exit(
    await Sesh(
      application,
      commands: commands(migrations: migrations, seeders: seeders),
    ).run(args),
  );
}
