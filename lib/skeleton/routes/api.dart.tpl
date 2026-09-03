import 'package:maat/maat.dart';

/// Routes served under `/api`.
void apiRoutes() {
  Route.get('/health', (Request request) => {'status': 'ok'});
}
