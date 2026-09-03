import 'package:maat/testing.dart';
import 'package:test/test.dart';

import '../../bootstrap/app.dart';

void main() {
  test('health endpoint responds', () async {
    final client = TestClient(await createApp());
    (await client.get('/api/health')).assertOk().assertJson({'status': 'ok'});
  });
}
