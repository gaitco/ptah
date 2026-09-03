import 'package:maat/maat.dart';

final Map<String, dynamic> view = {
  'paths': 'resources/views',
  'components': 'resources/views/components',
  // Parse templates once in production; reload them on edit in development.
  'cache': !envBool('APP_DEBUG'),
  'tailwind': {
    'version': env('TAILWIND_VERSION', '4.3.3'),
    'input': 'resources/css/app.css',
    'output': 'public/css/app.css',
  },
};
