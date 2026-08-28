import 'dart:convert';

import 'package:expense_tracker/core/errors/app_exception.dart';
import 'package:expense_tracker/features/auth/data/repositories/api_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers/fakes.dart';

void main() {
  late FakeApiClient api;
  late FakeTokenStorage storage;
  late ApiAuthRepository repository;

  setUp(() {
    api = FakeApiClient();
    storage = FakeTokenStorage();
    repository = ApiAuthRepository(api, storage);
  });

  String loginBody() => jsonEncode({
    'token': 'jwt-token-123',
    'user': {
      'id': 'user-42',
      'name': 'Test',
      'email': 'a@b.com',
      'role': 'Admin',
    },
  });

  test('login stores token + userId and returns userId', () async {
    api.handler = (method, path, body) => http.Response(loginBody(), 200);

    final userId = await repository.login('a@b.com', 'secret');

    expect(userId, 'user-42');
    expect(storage.token, 'jwt-token-123');
    expect(storage.userId, 'user-42');
    expect(storage.email, 'a@b.com');
    expect(storage.role, 'admin');
    expect(repository.getCurrentUserRole(), 'admin');
    expect(api.requests.single.path, '/auth/login');
    expect(api.requests.single.method, 'POST');
  });

  test('login reads role from JWT when user.role is omitted', () async {
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'role': 'admin',
      'sub': 'user-42',
    })));
    final token = 'header.$payload.sig';
    api.handler = (method, path, body) => http.Response(
          jsonEncode({
            'token': token,
            'user': {
              'id': 'user-42',
              'name': 'Test',
              'email': 'boss@test.com',
            },
          }),
          200,
        );

    await repository.login('boss@test.com', 'secret');

    expect(storage.role, 'admin');
  });

  test(
    'login throws AppException with API detail and does not store a token',
    () async {
      api.handler = (method, path, body) => http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'title': 'Unauthorized',
            'status': 401,
            'detail': 'E-posta veya şifre hatalı.',
            'traceId': 'auth-trace',
          }),
        ),
        401,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

      await expectLater(
        repository.login('a@b.com', 'wrong'),
        throwsA(
          isA<AppException>()
              .having((e) => e.kind, 'kind', AppErrorKind.unauthorized)
              .having((e) => e.userMessage, 'message', contains('şifre'))
              .having((e) => e.traceId, 'traceId', 'auth-trace'),
        ),
      );
      expect(storage.token, isNull);
    },
  );

  test(
    'register posts to register then logs in, deriving name from email',
    () async {
      api.handler = (method, path, body) {
        if (path == '/auth/register') return http.Response('{}', 201);
        return http.Response(loginBody(), 200);
      };

      final userId = await repository.register(
        'john.doe@example.com',
        'secret',
      );

      expect(userId, 'user-42');
      expect(storage.token, 'jwt-token-123');
      expect(api.requests.length, 2);
      expect(api.requests[0].path, '/auth/register');
      expect(api.requests[1].path, '/auth/login');

      final registerBody = api.requests[0].body as Map<String, dynamic>;
      expect(registerBody['name'], 'john.doe');
      expect(registerBody['email'], 'john.doe@example.com');
    },
  );

  test('logout clears the stored session', () async {
    await storage.saveSession(token: 't', userId: 'u');

    await repository.logout();

    expect(storage.token, isNull);
    expect(storage.userId, isNull);
  });

  test('getCurrentUserId reflects stored session synchronously', () async {
    expect(repository.getCurrentUserId(), isNull);
    await storage.saveSession(token: 't', userId: 'user-7', email: 'x@y.com');
    expect(repository.getCurrentUserId(), 'user-7');
    expect(repository.getCurrentUserEmail(), 'x@y.com');
    expect(repository.getCurrentUserRole(), isNull);

    await storage.saveSession(
      token: 't',
      userId: 'user-7',
      email: 'x@y.com',
      role: 'ADMIN',
    );
    expect(repository.getCurrentUserRole(), 'admin');
  });

  test('requestPasswordReset parses message and optional resetToken', () async {
    api.handler = (method, path, body) => http.Response(
      jsonEncode({'message': 'ok-msg', 'resetToken': 'abc123'}),
      200,
    );

    final result = await repository.requestPasswordReset('a@b.com');

    expect(result.message, 'ok-msg');
    expect(result.resetToken, 'abc123');
    expect(api.requests.single.path, '/auth/forgot-password');
    expect(api.requests.single.body, {'email': 'a@b.com'});
  });

  test('resetPassword posts email token and newPassword', () async {
    api.handler = (method, path, body) => http.Response('{}', 200);

    await repository.resetPassword(
      email: 'a@b.com',
      token: 'tok',
      newPassword: 'N3wP@ss!',
    );

    expect(api.requests.single.path, '/auth/reset-password');
    expect(api.requests.single.body, {
      'email': 'a@b.com',
      'token': 'tok',
      'newPassword': 'N3wP@ss!',
    });
  });
}
