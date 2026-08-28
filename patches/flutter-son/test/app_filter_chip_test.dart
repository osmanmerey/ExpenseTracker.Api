import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/app_filter_chip.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Wrap(
        spacing: AppFilterMetrics.groupGap,
        runSpacing: AppFilterMetrics.groupGap,
        children: [child],
      ),
    ),
  );
}

void main() {
  testWidgets('selected and unselected chips share height and keep a check slot',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: const [
            AppFilterChip(label: 'Yeni → eski', selected: false, onSelected: _noop),
            AppFilterChip(label: 'Yeni → eski', selected: true, onSelected: _noop),
            AppFilterChip(label: 'Tutar ↓', selected: false, onSelected: _noop),
            AppFilterChip(label: 'Tutar ↑', selected: true, onSelected: _noop),
          ],
        ),
      ),
    );

    final sizes = tester
        .widgetList<AppFilterChip>(find.byType(AppFilterChip))
        .map((chip) => tester.getSize(find.byWidget(chip)))
        .toList();
    expect(sizes, hasLength(4));
    for (final size in sizes) {
      expect(size.height, AppFilterMetrics.height);
    }
    expect(sizes[0].width, sizes[1].width);
  });

  testWidgets('TR and EN sort labels stay on one line at the same height',
      (tester) async {
    for (final locale in const [Locale('tr'), Locale('en')]) {
      final l10n = lookupAppLocalizations(locale);
      await tester.pumpWidget(
        _wrap(
          AppFilterChip(
            label: l10n.sortDateNewest,
            selected: true,
            onSelected: _noop,
          ),
          locale: locale,
        ),
      );
      final size = tester.getSize(find.byType(AppFilterChip));
      expect(size.height, AppFilterMetrics.height);
    }
  });

  testWidgets('selected chip exposes toggle semantics', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppFilterChip(
          label: 'Gider',
          selected: true,
          onSelected: _noop,
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(AppFilterChip));
    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(
      semantics.hasFlag(SemanticsFlag.isSelected) ||
          semantics.hasFlag(SemanticsFlag.isToggled),
      isTrue,
    );
  });
}

void _noop(bool _) {}
