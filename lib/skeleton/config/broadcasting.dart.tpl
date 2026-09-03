import 'package:maat/maat.dart';

Map<String, dynamic> get broadcasting => {
  'default': env('BROADCAST_CONNECTION', 'log'),
  'connections': {
    'pusher': {
      'driver': 'pusher',
      'key': env('PUSHER_APP_KEY', ''),
      'secret': env('PUSHER_APP_SECRET', ''),
      'app_id': env('PUSHER_APP_ID', ''),
      'host': env('PUSHER_HOST', '127.0.0.1'),
      'port': envInt('PUSHER_PORT', 6001),
      'scheme': env('PUSHER_SCHEME', 'http'),
    },
    'log': {'driver': 'log'},
    'null': {'driver': 'null'},
  },
};
