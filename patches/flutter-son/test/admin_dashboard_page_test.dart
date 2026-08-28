import 'dart:convert';

import 'package:expense_tracker/core/l10n/app_locale.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:expense_tracker/features/auth/domain/models/forgot_password_result.dart';
import 'package:expense_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'helpers/fakes.dart';

class _Auth implements IAuthRepository {
  @override
  Future<String> login(String email, String password) async => 'u1';

  @override
  Future<String> register(String email, String password) async => 'u1';

  @override
  Future<void> logout() async {}

  @override
  String? getCurrentUserId() => 'u1';

  @override
  String? getCurrentUserEmail() => 'boss@test.com';

  @override
  String? getCurrentUserRole() => 'admin';

  @override
  Future<ForgotPasswordResult> requestPasswordReset(String email) async =>
      const ForgotPasswordResult(message: 'ok');

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {}
}

void main() {
  late FakeApiClient api;

  setUp(() {
    Get.testMode = true;
    api = FakeApiClient();
    Get.put<ApiClient>(api);
    Get.put(AuthController(_Auth()));
    api.handler = (method, path, body) => http.Response(
          jsonEncode([
            {
              'id': '1',
              'name': 'Ali Veli',
              'email': 'secret.one@example.com',
              'role': 'admin',
            },
            {
              'id': '2',
              'name': 'Ayse',
              'email': 'secret.two@example.com',
              'role': 'user',
            },
          ]),
          200,
        );
  });

  tearDown(Get.reset);

  testWidgets('dashboard shows compact user card and no financial data',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark(),
        locale: AppLocale.turkish,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AdminDashboardPage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Yönetim Paneli'), findsOneWidget);
    expect(
      find.text('Harcama veya finansal detay içermeyen operasyonel özet.'),
      findsOneWidget,
    );
    expect(find.text('Kullanıcılar'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Toplam kullanıcı'), findsOneWidget);
    expect(find.text('Yönetici: 1'), findsOneWidget);
    expect(find.text('Kullanıcı ekle ve sil'), findsOneWidget);
    expect(find.text('Roller ve yetkiler'), findsOneWidget);

    expect(find.text('Kullanım özeti'), findsNothing);
    expect(find.text('1 kayıtlı hesap'), findsNothing);
    expect(find.text('secret.one@example.com'), findsNothing);
    expect(find.text('Ali Veli'), findsNothing);
    expect(find.textContaining('₺'), findsNothing);
    expect(find.text('secret.one@example.com'), findsNothing);
    expect(find.text('Ali Veli'), findsNothing);
  });
}
