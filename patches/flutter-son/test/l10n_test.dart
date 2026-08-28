import 'package:expense_tracker/core/l10n/app_locale.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppLocale parse/store round-trips', () {
    expect(AppLocale.parseStored('tr'), AppLocale.turkish);
    expect(AppLocale.parseStored('en'), AppLocale.english);
    expect(AppLocale.parseStored('system'), isNull);
    expect(AppLocale.parseStored(null), isNull);
    expect(AppLocale.store(null), 'system');
    expect(AppLocale.store(AppLocale.english), 'en');
  });

  test('lookupAppLocalizations returns TR and EN strings', () {
    final tr = lookupAppLocalizations(AppLocale.turkish);
    final en = lookupAppLocalizations(AppLocale.english);

    expect(tr.settingsTitle, 'Profil ve ayarlar');
    expect(en.settingsTitle, 'Profile & settings');
    expect(tr.income, 'Gelir');
    expect(en.income, 'Income');
    expect(tr.recordsCount(3), '3 kayıt');
    expect(en.recordsCount(3), '3 records');
    expect(tr.adminPanelTitle, 'Yönetim Paneli');
    expect(en.adminPanelTitle, 'Admin Panel');
    expect(
      tr.adminPanelSubtitle,
      'Harcama veya finansal detay içermeyen operasyonel özet.',
    );
    expect(tr.adminPanelSubtitle.contains('Kişisel finansal veri'), isFalse);
    expect(tr.logoutConfirmAction, 'Oturumu sonlandır');
    expect(en.logoutConfirmAction, 'End session');
    expect(en.currencyAll, 'Currency: All');
    expect(en.sortDateNewest, 'Newest → oldest');
    expect(en.sortDateOldest, 'Oldest → newest');
    expect(tr.sortDateNewest, 'Yeni → eski');
    expect(tr.kindAll, 'Tür: Tümü');
    expect(en.kindAll, 'Type: All');
    expect(tr.adminPortalSignIn, 'Yönetici paneli');
    expect(en.adminPortalSignIn, 'Admin panel');
  });

  testWidgets('MaterialApp resolves AppLocalizations.of', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: AppLocale.english,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return Text(l10n.logout);
          },
        ),
      ),
    );

    expect(find.text('Log out'), findsOneWidget);
    expect(l10n.languageEnglish, 'English');
  });
}
