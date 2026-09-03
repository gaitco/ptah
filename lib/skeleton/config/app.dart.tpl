import 'package:maat/maat.dart';

final Map<String, dynamic> app = {
  'name': env('APP_NAME', 'Maat'),
  'env': env('APP_ENV', 'production'),
  'debug': envBool('APP_DEBUG'),
  'url': env('APP_URL', 'http://localhost:8000'),
  'key': env('APP_KEY'),
  'timezone': env('APP_TIMEZONE', 'UTC'),
  'locale': env('APP_LOCALE', 'en'),
  'log_path': 'storage/logs/maat.log',
};
