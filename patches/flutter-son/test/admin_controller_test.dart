import 'dart:convert';

import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/admin/controllers/admin_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'helpers/fakes.dart';

void main() {
  late FakeApiClient api;

  setUp(() {
    Get.testMode = true;
    api = FakeApiClient();
    Get.put<ApiClient>(api);
  });

  tearDown(Get.reset);

  test('loadOverview keeps directory names and aggregate counts', () async {
    api.handler = (method, path, body) => http.Response(
          jsonEncode([
            {
              'id': '1',
              'name': 'Ada',
              'email': 'secret.one@example.com',
              'role': 'admin',
            },
            {
              'id': '2',
              'name': 'Bora',
              'email': 'secret.two@example.com',
              'role': 'user',
            },
            {
              'id': '3',
              'name': 'Cem',
              'email': 'secret.three@example.com',
              'role': 'ADMIN',
            },
          ]),
          200,
        );

    final controller = AdminController();
    await controller.loadOverview();

    expect(api.requests.single.path, '/users');
    expect(controller.hasError.value, isFalse);
    expect(controller.isApiReachable.value, isTrue);
    expect(controller.userCount.value, 3);
    expect(controller.adminAccountCount.value, 2);
    expect(controller.users.map((u) => u.displayName('x')), ['Ada', 'Bora', 'Cem']);
  });

  test('createUser posts register then reloads the directory', () async {
    var created = false;
    api.handler = (method, path, body) {
      if (method == 'POST' && path == '/auth/register') {
        created = true;
        return http.Response(
          jsonEncode({'id': '9', 'name': 'New', 'email': 'n@x.com', 'role': 'user'}),
          201,
        );
      }
      return http.Response(
        jsonEncode([
          {'id': '9', 'name': 'New', 'email': 'n@x.com', 'role': 'user'},
        ]),
        200,
      );
    };

    final controller = AdminController();
    await controller.loadOverview();
    final error = await controller.createUser(
      name: 'New',
      email: 'n@x.com',
      password: 'secret12',
    );

    expect(error, isNull);
    expect(created, isTrue);
    expect(controller.users.single.name, 'New');
  });

  test('deleteUser and updateRole call admin endpoints', () async {
    api.handler = (method, path, body) {
      if (method == 'DELETE') {
        expect(path, '/users/2');
        return http.Response('', 204);
      }
      if (method == 'PUT') {
        expect(path, '/users/2/role');
        return http.Response('', 204);
      }
      return http.Response(
        jsonEncode([
          {'id': '2', 'name': 'Bora', 'email': 'b@x.com', 'role': 'user'},
        ]),
        200,
      );
    };

    final controller = AdminController();
    expect(await controller.updateRole('2', 'admin'), isNull);
    expect(await controller.deleteUser('2'), isNull);
    expect(
      api.requests.map((r) => '${r.method} ${r.path}'),
      containsAll(['PUT /users/2/role', 'DELETE /users/2']),
    );
  });

  test('empty user list is a real zero, not mocked data', () async {
    api.handler = (method, path, body) => http.Response(jsonEncode([]), 200);

    final controller = AdminController();
    await controller.loadOverview();

    expect(controller.hasError.value, isFalse);
    expect(controller.userCount.value, 0);
    expect(controller.adminAccountCount.value, 0);
    expect(controller.isApiReachable.value, isTrue);
  });

  test('failed overview request does not invent counts', () async {
    api.handler = (method, path, body) => http.Response('', 403);

    final controller = AdminController();
    await controller.loadOverview();

    expect(controller.hasError.value, isTrue);
    expect(controller.isApiReachable.value, isFalse);
    expect(controller.userCount.value, 0);
    expect(controller.adminAccountCount.value, 0);
  });
}
