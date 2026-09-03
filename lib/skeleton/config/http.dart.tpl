import 'package:maat/maat.dart';

final Map<String, dynamic> http = {
  'max_body_bytes': envInt('HTTP_MAX_BODY_BYTES', 10 * 1024 * 1024),
};
