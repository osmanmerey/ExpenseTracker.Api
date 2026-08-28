import 'package:expense_tracker/core/l10n/app_locale.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/logout_confirm_dialog.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TR copy and cancel keep the session', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: AppLocale.turkish,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showLogoutConfirmDialog(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      find.text('Oturumu sonlandırmak istediğinize emin misiniz?'),
      findsOneWidget,
    );
    expect(
      find.text('Oturumunuz kapatılacak. Devam etmek istiyor musunuz?'),
      findsOneWidget,
    );
    expect(find.text('Oturumu sonlandır'), findsOneWidget);
    expect(find.text('Vazgeç'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text('Oturumu sonlandır'), findsNothing);
  });

  testWidgets('EN confirm returns true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: AppLocale.english,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showLogoutConfirmDialog(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to end your session?'), findsOneWidget);
    expect(find.text('End session'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('Escape dismisses without ending the session', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: AppLocale.english,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showLogoutConfirmDialog(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
