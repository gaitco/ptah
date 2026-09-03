import 'dart:io';

import 'package:maat/maat.dart';
import 'package:amarna/amarna.dart';
import 'package:seshat_maat/seshat_maat.dart';{{ view_import }}
import 'package:{{ name }}/app/providers/app_service_provider.dart';
import 'package:{{ name }}/app/providers/route_service_provider.dart';

import '../config/config.dart';
import '../routes/api.dart';
import '../routes/web.dart';

/// Build the application. Mirrors Laravel's bootstrap/app.php.
Future<Application> createApp() =>
    Application.configure(
          basePath:
              Platform.environment['APP_BASE_PATH'] ?? Directory.current.path,
        )
        .withConfig(appConfig)
        .withProviders([
          AppServiceProvider.new,
          DatabaseServiceProvider.new,{{ view_provider }}
          MailServiceProvider.new,
          (app) => RouteServiceProvider(app, api: apiRoutes, web: webRoutes),
        ])
        .withMiddleware(
          (middleware) => middleware
              .use([PublicFiles(publicPath()), TrimStrings(), Cors()])
              .alias({'throttle': ThrottleRequests.factory}),
        )
        .withExceptions((exceptions) {
          // exceptions.report((error, stackTrace) => ...);
          // exceptions.render<MyException>((error, request) => Response.json({...}, status: 400));
        })
        .create();
