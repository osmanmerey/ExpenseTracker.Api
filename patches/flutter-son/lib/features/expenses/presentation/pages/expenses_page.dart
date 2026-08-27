import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_kind.dart';
import '../controllers/expense_controller.dart';
import '../widgets/category_pie_chart.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Yemek':
        return Icons.restaurant_outlined;
      case 'Ulaşım':
        return Icons.directions_bus_outlined;
      case 'Fatura':
        return Icons.receipt_long_outlined;
      case 'Market':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    final fabBottom = 16 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
        actions: [
          IconButton(
            tooltip: l10n.tooltipSettings,
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Obx(() {
                switch (controller.viewState.value) {
                  case ViewState.loading:
                    return const Center(child: CircularProgressIndicator());

                  case ViewState.error:
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 56,
                              color: colors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.connectionErrorTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () => controller.loadExpenses(),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    );

                  case ViewState.empty:
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 72,
                              color: colors.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noRecordsYet,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noRecordsHint,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.expenseForm),
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addRecord),
                            ),
                          ],
                        ),
                      ),
                    );

                  case ViewState.stale:
                  case ViewState.success:
                    return _ExpensesScrollBody(
                      controller: controller,
                      isStale: controller.viewState.value == ViewState.stale,
                      theme: theme,
                      colors: colors,
                      categoryIcon: _categoryIcon,
                      confirmDelete: _confirmDelete,
                    );
                }
              }),
            ),
            Positioned(
              right: 16,
              bottom: fabBottom,
              child: FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.expenseForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Expense expense) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteExpenseTitle),
        content: Text(
          l10n.deleteExpenseBody(expense.category, expense.currency.code),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _ExpensesScrollBody extends StatefulWidget {
  final ExpenseController controller;
  final bool isStale;
  final ThemeData theme;
  final ColorScheme colors;
  final IconData Function(String) categoryIcon;
  final Future<bool?> Function(BuildContext, Expense) confirmDelete;

  const _ExpensesScrollBody({
    required this.controller,
    required this.isStale,
    required this.theme,
    required this.colors,
    required this.categoryIcon,
    required this.confirmDelete,
  });

  @override
  State<_ExpensesScrollBody> createState() => _ExpensesScrollBodyState();
}

class _ExpensesScrollBodyState extends State<_ExpensesScrollBody> {
  final _scrollController = ScrollController();
  Worker? _pageWorker;

  ExpenseController get controller => widget.controller;
  ThemeData get theme => widget.theme;
  ColorScheme get colors => widget.colors;
  IconData Function(String) get categoryIcon => widget.categoryIcon;
  Future<bool?> Function(BuildContext, Expense) get confirmDelete =>
      widget.confirmDelete;
  bool get isStale => widget.isStale;

  @override
  void initState() {
    super.initState();
    _pageWorker = ever(controller.currentPage, (_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _pageWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = theme.brightness;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 120;
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () => controller.loadExpenses(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (isStale)
            SliverToBoxAdapter(
              child: MaterialBanner(
                content: Text(
                  controller.errorMessage.value.isEmpty
                      ? l10n.staleDataMessage
                      : controller.errorMessage.value,
                ),
                leading: Icon(
                  Icons.wifi_off,
                  color: colors.onTertiaryContainer,
                ),
                backgroundColor: colors.tertiaryContainer,
                actions: [
                  TextButton(
                    onPressed: () => controller.loadExpenses(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: Material(
              color: colors.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Obx(() {
                  final expenseTry = controller.totalInTry;
                  final incomeTry = controller.incomeTotalInTry;
                  final netTry = controller.netTotalInTry;
                  final count = controller.visibleExpenses.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.netTotalLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppCurrency.tryLira.format(netTry),
                        style: AppTypography.price(
                          fontSize: 28,
                          color: netTry >= 0 ? colors.primary : colors.error,
                          brightness: brightness,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryStat(
                              label: l10n.income,
                              value: AppCurrency.tryLira.format(incomeTry),
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryStat(
                              label: l10n.expense,
                              value: AppCurrency.tryLira.format(expenseTry),
                              color: colors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.fxRatesHint} · ${l10n.recordsCount(count)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Obx(() {
                      final kind = controller.kindFilter.value;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _fixedFilterChip(
                              label: Text(l10n.kindAll),
                              selected: kind == null,
                              onSelected: (selected) {
                                if (selected) controller.setKindFilter(null);
                              },
                            ),
                            const SizedBox(width: 8),
                            _fixedFilterChip(
                              label: Text(l10n.expense),
                              selected: kind == TransactionKind.expense,
                              onSelected: (selected) =>
                                  controller.setKindFilter(
                                    selected ? TransactionKind.expense : null,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _fixedFilterChip(
                              label: Text(l10n.income),
                              selected: kind == TransactionKind.income,
                              onSelected: (selected) =>
                                  controller.setKindFilter(
                                    selected ? TransactionKind.income : null,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    final count = controller.advancedFilterCount;
                    final open = controller.showFiltersPanel.value;
                    return TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        iconSize: _kFilterIconSize,
                      ),
                      onPressed: controller.toggleFiltersPanel,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Badge(
                            isLabelVisible: count > 0,
                            label: Text('$count'),
                            child: _FixedFilterIcon(
                              Icons.tune,
                              color: open ? colors.primary : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            count > 0
                                ? l10n.filtersActive(count)
                                : l10n.filters,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (!controller.showFiltersPanel.value) {
                return const SizedBox.shrink();
              }
              return _FiltersPanel(controller: controller);
            }),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (!controller.showChart.value) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: controller.toggleChart,
                    style: TextButton.styleFrom(
                      iconSize: _kFilterIconSize,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FixedFilterIcon(Icons.pie_chart_outline),
                        const SizedBox(width: 6),
                        Text(l10n.showChart),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: controller.toggleChart,
                      style: TextButton.styleFrom(
                        iconSize: _kFilterIconSize,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FixedFilterIcon(Icons.pie_chart),
                          const SizedBox(width: 6),
                          Text(l10n.hideChart),
                        ],
                      ),
                    ),
                  ),
                  CategoryPieChart(expenses: controller.visibleExpenseOnly),
                ],
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: Obx(() {
              final visible = controller.visibleExpenses;
              if (visible.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: Center(
                    child: Text(
                      controller.hasActiveListFilters
                          ? l10n.noFilterMatches
                          : l10n.noCurrencyMatches,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              final paged = controller.pagedExpenses;
              return Column(
                children: [
                  for (final expense in paged)
                    Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => confirmDelete(context, expense),
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete_outline,
                          color: colors.onError,
                        ),
                      ),
                      onDismissed: (_) async {
                        final ok = await controller.deleteExpense(expense.id);
                        if (!ok) return;
                        Get.snackbar(
                          l10n.deleted,
                          l10n.expenseDeleted,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.categoryColor(
                              expense.category,
                              brightness: brightness,
                            ).withValues(alpha: 0.18),
                            foregroundColor: AppColors.categoryColor(
                              expense.category,
                              brightness: brightness,
                            ),
                            child: Icon(
                              categoryIcon(expense.category),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            expense.category,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            [
                              expense.kind.label(l10n),
                              '${expense.date.day}.${expense.date.month}.${expense.date.year}',
                              expense.currency.code,
                              if (expense.description.trim().isNotEmpty)
                                expense.description.trim(),
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          trailing: Text(
                            '${expense.kind == TransactionKind.income ? '+' : '-'}${expense.currency.format(expense.amount)}',
                            textAlign: TextAlign.right,
                            style: AppTypography.price(
                              fontSize: 16,
                              brightness: brightness,
                              color: expense.kind == TransactionKind.income
                                  ? colors.primary
                                  : colors.error,
                            ),
                          ),
                          onTap: () => Get.toNamed(
                            AppRoutes.expenseForm,
                            arguments: expense,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _ExpensePageNumbers(
                    currentPage: controller.currentPage.value,
                    pageCount: controller.pageCount,
                    onPageSelected: controller.goToPage,
                    labelBuilder: l10n.pageNumber,
                  ),
                ],
              );
            }),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ExpensePageNumbers extends StatelessWidget {
  const _ExpensePageNumbers({
    required this.currentPage,
    required this.pageCount,
    required this.onPageSelected,
    required this.labelBuilder,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageSelected;
  final String Function(int page) labelBuilder;

  static final ButtonStyle _pageButtonStyle = FilledButton.styleFrom(
    minimumSize: const Size(40, 40),
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static final ButtonStyle _pageTextStyle = TextButton.styleFrom(
    minimumSize: const Size(40, 40),
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 96, 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var page = 1; page <= pageCount; page++)
            page == currentPage
                ? FilledButton(
                    style: _pageButtonStyle,
                    onPressed: () {},
                    child: Text(labelBuilder(page)),
                  )
                : TextButton(
                    style: _pageTextStyle,
                    onPressed: () => onPageSelected(page),
                    child: Text(labelBuilder(page)),
                  ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends StatefulWidget {
  final ExpenseController controller;

  const _FiltersPanel({required this.controller});

  @override
  State<_FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<_FiltersPanel> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDay(DateTime d) => '${d.day}.${d.month}.${d.year}';

  Future<void> _pickDateRange() async {
    final controller = widget.controller;
    final from = controller.dateFrom.value;
    final to = controller.dateTo.value;
    final l10n = context.l10n;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: from != null && to != null
          ? DateTimeRange(start: from, end: to)
          : null,
      helpText: l10n.dateRange,
      saveText: l10n.applyFilters,
    );
    if (picked != null) {
      controller.setDateRange(from: picked.start, to: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              onChanged: controller.setSearchQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const _FixedFilterIcon(Icons.search),
                prefixIconConstraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                isDense: true,
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.setSearchQuery('');
                    },
                    icon: const _FixedFilterIcon(Icons.clear),
                    iconSize: _kFilterIconSize,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                  );
                }),
                suffixIconConstraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(l10n.currency, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Obx(() {
              final selected = controller.currencyFilter.value;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.currencyAll),
                    selected: selected == null,
                    onSelected: (selectedChip) {
                      if (selectedChip) controller.setCurrencyFilter(null);
                    },
                    avatarBoxConstraints: _filterAvatarConstraints,
                    iconTheme: _filterIconTheme,
                  ),
                  for (final c in AppCurrency.values)
                    FilterChip(
                      label: Text(c.code),
                      selected: selected == c,
                      onSelected: (selectedChip) =>
                          controller.setCurrencyFilter(selectedChip ? c : null),
                      avatarBoxConstraints: _filterAvatarConstraints,
                      iconTheme: _filterIconTheme,
                    ),
                ],
              );
            }),
            const SizedBox(height: 10),
            Obx(() {
              final from = controller.dateFrom.value;
              final to = controller.dateTo.value;
              final hasRange = from != null && to != null;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDateRange,
                      style: OutlinedButton.styleFrom(
                        iconSize: _kFilterIconSize,
                      ),
                      child: Row(
                        children: [
                          const _FixedFilterIcon(Icons.date_range_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hasRange
                                  ? '${_formatDay(from)} – ${_formatDay(to)}'
                                  : l10n.dateRange,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasRange) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => controller.setDateRange(),
                      icon: const _FixedFilterIcon(Icons.event_busy_outlined),
                      iconSize: _kFilterIconSize,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 10),
            Text(l10n.sortLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Obx(() {
              final mode = controller.sortMode.value;
              final options = [
                (ExpenseSortMode.dateNewest, l10n.sortDateNewest),
                (ExpenseSortMode.dateOldest, l10n.sortDateOldest),
                (ExpenseSortMode.amountHigh, l10n.sortAmountHigh),
                (ExpenseSortMode.amountLow, l10n.sortAmountLow),
              ];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in options)
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: mode == entry.$1,
                      onSelected: (selected) {
                        if (selected) controller.setSortMode(entry.$1);
                      },
                      avatarBoxConstraints: _filterAvatarConstraints,
                      iconTheme: _filterIconTheme,
                    ),
                ],
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  controller.clearListFilters();
                },
                child: Text(l10n.clearFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _kFilterIconSize = 20.0;

const _filterAvatarConstraints = BoxConstraints.tightFor(
  width: _kFilterIconSize,
  height: _kFilterIconSize,
);

const _filterIconTheme = IconThemeData(size: _kFilterIconSize);

class _FixedFilterIcon extends StatelessWidget {
  const _FixedFilterIcon(this.icon, {this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _kFilterIconSize,
      child: Icon(icon, size: _kFilterIconSize, color: color),
    );
  }
}

FilterChip _fixedFilterChip({
  required Widget label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return FilterChip(
    label: label,
    selected: selected,
    onSelected: onSelected,
    avatarBoxConstraints: _filterAvatarConstraints,
    iconTheme: _filterIconTheme,
  );
}

