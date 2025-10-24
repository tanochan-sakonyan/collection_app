import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mr_collection/utils/authenticated_request.dart';
import 'package:mr_collection/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sendWithAuth refreshes token on 401 and retries request', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'expired-access',
      'refresh_token': 'refresh-token',
    });

    var requestCallCount = 0;

    final mockClient = MockClient((request) async {
      expect(request.url.toString(), 'https://example.com/auth/refresh');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['refresh_token'], 'refresh-token');

      return http.Response(
        jsonEncode({
          'access_token': 'new-access',
          'refresh_token': 'new-refresh',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final helper = AuthenticatedRequestHelper(
      baseUrl: 'https://example.com',
      client: mockClient,
      contextLabel: 'TestHelper',
    );

    final response = await helper.sendWithAuth((token) async {
      requestCallCount += 1;
      if (requestCallCount == 1) {
        expect(token, 'expired-access');
        return http.Response(
          jsonEncode({'message': 'Token has expired!'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      expect(token, 'new-access');
      return http.Response('OK', 200);
    });

    expect(response.statusCode, 200);
    expect(requestCallCount, 2);

    expect(await TokenStorage.getAccessToken(), 'new-access');
    expect(await TokenStorage.getRefreshToken(), 'new-refresh');
  });
}
