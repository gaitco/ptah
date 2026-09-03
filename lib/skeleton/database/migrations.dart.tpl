import 'package:seshat_maat/seshat_maat.dart';
import 'package:sistrum/sistrum.dart';

/// Every migration, in the order they run.
final migrations = <Migration>[
  ...sistrumMigrations,
  // `make:migration` registers new migrations here.
];
