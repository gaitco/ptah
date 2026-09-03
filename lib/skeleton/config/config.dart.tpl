import 'app.dart';
import 'cors.dart';
import 'database.dart';{{ view_config_import }}
import 'http.dart';
import 'mail.dart';

/// Every config file, keyed by the name used in `config('name.key')`.
final Map<String, dynamic> appConfig = {
  'app': app,
  'cors': cors,
  'database': database,{{ view_config_entry }}
  'http': http,
  'mail': mail,
};
