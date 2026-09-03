import 'package:seshat_maat/seshat_maat.dart';

/// Every seeder `db:seed` runs, in order. `make:seeder` creates new seeders
/// in this directory; add them here to register them.
final seeders = <Seeder>[DatabaseSeeder()];

class DatabaseSeeder extends Seeder {
  @override
  Future<void> run() async {}
}
