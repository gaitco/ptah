import 'package:maat/maat.dart';

Map<String, dynamic> get thoth => {
  'host': env('THOTH_HOST', '0.0.0.0'),
  'port': envInt('THOTH_PORT', 6001),
  'app': {
    'id': env('PUSHER_APP_ID', ''),
    'key': env('PUSHER_APP_KEY', ''),
    'secret': env('PUSHER_APP_SECRET', ''),
  },
  'client_events': envBool('THOTH_CLIENT_EVENTS', false),
  'activity_timeout': envInt('THOTH_ACTIVITY_TIMEOUT', 120),
  'pong_timeout': envInt('THOTH_PONG_TIMEOUT', 30),
  'max_connections': envInt('THOTH_MAX_CONNECTIONS', 0),
};
