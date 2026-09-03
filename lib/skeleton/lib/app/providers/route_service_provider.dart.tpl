import 'package:maat/maat.dart';

class RouteServiceProvider extends ServiceProvider {
  RouteServiceProvider(
    super.app, {
    required this.api,
    required this.channels,
    required this.web,
  });

  final void Function() api;
  final void Function() channels;
  final void Function() web;

  @override
  void boot() {
    channels();
    Route.prefix('api').group(api);
    web();
  }
}
