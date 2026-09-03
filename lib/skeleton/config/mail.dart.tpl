import 'package:maat/maat.dart';

final Map<String, dynamic> mail = {
  'default': env('MAIL_MAILER', 'log'),
  'mailers': {
    'smtp': {
      'transport': 'smtp',
      'host': env('MAIL_HOST', '127.0.0.1'),
      'port': envInt('MAIL_PORT', 587),
      'username': env('MAIL_USERNAME'),
      'password': env('MAIL_PASSWORD'),
      'encryption': env('MAIL_ENCRYPTION', 'tls'),
    },
    'log': {'transport': 'log'},
    'array': {'transport': 'array'},
  },
  'from': {
    'address': env('MAIL_FROM_ADDRESS', 'hello@example.com'),
    'name': env('MAIL_FROM_NAME', 'Example'),
  },
};
