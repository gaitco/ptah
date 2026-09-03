import 'package:maat/maat.dart';

class RouteServiceProvider extends ServiceProvider {
  RouteServiceProvider(super.app, {required this.api, required this.web});

  final void Function() api;
  final void Function() web;

  @override
  void boot() {
    Route.prefix('api').group(api);
    web();
  }
}
