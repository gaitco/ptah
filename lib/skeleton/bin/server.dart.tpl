import 'dart:io';

import 'package:maat/maat.dart';

import '../bootstrap/app.dart';

Future<void> main() async {
  final basePath =
      Platform.environment['APP_BASE_PATH'] ?? Directory.current.path;
  Env.load(Directory(basePath).uri.resolve('.env').toFilePath());
  final workers = envInt('APP_WORKERS', 1);
  if (workers > 1) {
    final server = await Application.serveWorkers(
      createApp,
      host: env('APP_HOST', '0.0.0.0')!,
      port: envInt('APP_PORT', 8000),
      workers: workers,
    );
    await server.waitForShutdownSignal();
    return;
  }
  final application = await createApp();
  await application.serve(
    host: env('APP_HOST', '0.0.0.0')!,
    port: envInt('APP_PORT', 8000),
  );
  await application.waitForShutdownSignal();
}
