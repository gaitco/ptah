import 'package:maat/maat.dart';

final Map<String, dynamic> database = {
  'default': env('DB_CONNECTION', 'sqlite'),
  'connections': {
    'sqlite': {
      'driver': 'sqlite',
      'database': env('DB_DATABASE', 'database/database.sqlite'),
      // No 'foreign_key_constraints' key: the SQLite adapter always issues
      // `pragma foreign_keys = on`, so a switch here would read as a working
      // setting while doing nothing.
    },
    'pgsql': {
      'driver': 'pgsql',
      'host': env('DB_HOST', '127.0.0.1'),
      'port': envInt('DB_PORT', 5432),
      'database': env('DB_DATABASE', 'maat'),
      'username': env('DB_USERNAME', 'postgres'),
      'password': env('DB_PASSWORD', ''),
      // 'disable' turns TLS off; any other value (e.g. 'require') turns it
      // on. The adapter only has an on/off switch, so it cannot tell
      // 'require' from 'verify-full' — there is no partial credit here.
      'ssl': env('DB_SSL', 'disable'),
      'pool': {'max': envInt('DB_POOL_MAX', 5)},
    },
    'mysql': {
      'driver': 'mysql',
      'host': env('DB_HOST', '127.0.0.1'),
      'port': envInt('DB_PORT', 3306),
      'database': env('DB_DATABASE', 'maat'),
      'username': env('DB_USERNAME', 'root'),
      'password': env('DB_PASSWORD', ''),
      'pool': {'max': envInt('DB_POOL_MAX', 10)},
    },
  },
};
