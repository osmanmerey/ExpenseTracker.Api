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

  test('loadOverview stores only aggregate counts, not emails', () async {
    api.handler = (method, path, body) => http.Response(
          jsonEncode([
            {'id': '1', 'email': 'secret.one@example.com', 'role': 'admin'},
            {'id': '2', 'email': 'secret.two@example.com', 'role': 'user'},
            {'id': '3', 'email': 'secret.three@example.com', 'role': 'ADMIN'},
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
