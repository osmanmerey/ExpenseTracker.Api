import 'package:get/get.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/fixed_exchange_rates.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/budget_alert_coordinator.dart';
import '../../../../core/utils/turkish_text.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_kind.dart';
import '../../domain/repositories/i_expense_repository.dart';

enum ViewState { loading, empty, error, success, stale }

enum ExpenseSortMode {
  dateNewest,
  dateOldest,
  amountHigh,
  amountLow,
}

class ExpenseController extends GetxController {
  final IExpenseRepository _expenseRepository;
  final IAuthRepository _authRepository;

  ExpenseController(this._expenseRepository, this._authRepository);

  var viewState = ViewState.loading.obs;
  var expenses = <Expense>[].obs;
  var errorMessage = ''.obs;
  var isSaving = false.obs;

  /// Display-only filters. Never mutate stored expense records.
  final currencyFilter = Rxn<AppCurrency>();
  final kindFilter = Rxn<TransactionKind>();
  final searchQuery = ''.obs;
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();
  final sortMode = ExpenseSortMode.dateNewest.obs;
  final showChart = false.obs;
  final showFiltersPanel = false.obs;
  final currentPage = 1.obs;

  /// Client-side page size. The expenses API returns the full list.
  static const int listPageSize = 10;

  @override
  void onInit() {
    super.onInit();
    if (_authRepository.getCurrentUserId() != null) {
      loadExpenses();
    } else {
      viewState.value = ViewState.empty;
    }
  }

  bool get hasActiveListFilters =>
      currencyFilter.value != null ||
      kindFilter.value != null ||
      searchQuery.value.trim().isNotEmpty ||
      dateFrom.value != null ||
      dateTo.value != null ||
      sortMode.value != ExpenseSortMode.dateNewest;

  /// Active filters shown in the Filters badge (includes kind chips).
  int get advancedFilterCount {
    var n = 0;
    if (kindFilter.value != null) n++;
    if (currencyFilter.value != null) n++;
    if (searchQuery.value.trim().isNotEmpty) n++;
    if (dateFrom.value != null || dateTo.value != null) n++;
    if (sortMode.value != ExpenseSortMode.dateNewest) n++;
    return n;
  }

  void _refreshBudgetsIfPresent() {
    if (Get.isRegistered<BudgetController>()) {
      // ignore: unawaited_futures
      Get.find<BudgetController>().loadBudgets();
    }
  }

  void toggleChart() => showChart.value = !showChart.value;

  void toggleFiltersPanel() => showFiltersPanel.value = !showFiltersPanel.value;

  List<Expense> get visibleExpenses {
    Iterable<Expense> list = expenses;

    final currency = currencyFilter.value;
    if (currency != null) {
      list = list.where((e) => e.currency == currency);
    }

    final kind = kindFilter.value;
    if (kind != null) {
      list = list.where((e) => e.kind == kind);
    }

    final query = searchQuery.value.trim();
    if (query.isNotEmpty) {
      list = list.where((e) {
        final kindEn = e.kind == TransactionKind.income ? 'income' : 'expense';
        final haystack =
            '${e.category} ${e.description} ${e.currency.code} ${e.kind.labelTr} $kindEn';
        return turkishContains(haystack, query);
      });
    }

    final from = dateFrom.value;
    if (from != null) {
      final start = DateTime(from.year, from.month, from.day);
      list = list.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isBefore(start);
      });
    }

    final to = dateTo.value;
    if (to != null) {
      final end = DateTime(to.year, to.month, to.day);
      list = list.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isAfter(end);
      });
    }

    final sorted = list.toList();
    switch (sortMode.value) {
      case ExpenseSortMode.dateNewest:
        sorted.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortMode.dateOldest:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortMode.amountHigh:
        sorted.sort((a, b) {
          final aTry =
              FixedExchangeRates.convertToTryAmount(a.amount, a.currency);
          final bTry =
              FixedExchangeRates.convertToTryAmount(b.amount, b.currency);
          return bTry.compareTo(aTry);
        });
      case ExpenseSortMode.amountLow:
        sorted.sort((a, b) {
          final aTry =
              FixedExchangeRates.convertToTryAmount(a.amount, a.currency);
          final bTry =
              FixedExchangeRates.convertToTryAmount(b.amount, b.currency);
          return aTry.compareTo(bTry);
        });
    }
    return sorted;
  }

  int get pageCount {
    final n = visibleExpenses.length;
    if (n <= 0) return 1;
    return (n / listPageSize).ceil();
  }

  List<Expense> get pagedExpenses {
    final all = visibleExpenses;
    if (all.isEmpty) return const [];
    final page = currentPage.value.clamp(1, pageCount);
    final start = (page - 1) * listPageSize;
    if (start >= all.length) return const [];
    final end = (start + listPageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void goToPage(int page) {
    currentPage.value = page.clamp(1, pageCount);
  }

  void _resetPage() {
    currentPage.value = 1;
  }

  void _clampPage() {
    final maxPage = pageCount;
    if (currentPage.value > maxPage) {
      currentPage.value = maxPage;
    }
  }

  void setCurrencyFilter(AppCurrency? currency) {
    currencyFilter.value = currency;
    _resetPage();
  }

  void setKindFilter(TransactionKind? kind) {
    kindFilter.value = kind;
    _resetPage();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _resetPage();
  }

  void setDateRange({DateTime? from, DateTime? to}) {
    dateFrom.value = from;
    dateTo.value = to;
    _resetPage();
  }

  void setSortMode(ExpenseSortMode mode) {
    sortMode.value = mode;
    _resetPage();
  }

  void clearListFilters() {
    kindFilter.value = null;
    clearAdvancedFilters();
  }

  void clearAdvancedFilters() {
    currencyFilter.value = null;
    searchQuery.value = '';
    dateFrom.value = null;
    dateTo.value = null;
    sortMode.value = ExpenseSortMode.dateNewest;
    _resetPage();
  }

  Iterable<({double amount, AppCurrency currency})> get _visibleExpenseRows =>
      visibleExpenses
          .where((e) => e.kind == TransactionKind.expense)
          .map((e) => (amount: e.amount, currency: e.currency));

  Iterable<({double amount, AppCurrency currency})> get _visibleIncomeRows =>
      visibleExpenses
          .where((e) => e.kind == TransactionKind.income)
          .map((e) => (amount: e.amount, currency: e.currency));

  Map<AppCurrency, double> get totalsByCurrency =>
      FixedExchangeRates.totalsByCurrency(_visibleExpenseRows);

  double get totalInTry => FixedExchangeRates.totalInTry(_visibleExpenseRows);

  double get incomeTotalInTry =>
      FixedExchangeRates.totalInTry(_visibleIncomeRows);

  double get netTotalInTry => incomeTotalInTry - totalInTry;

  List<Expense> get visibleExpenseOnly => visibleExpenses
      .where((e) => e.kind == TransactionKind.expense)
      .toList();

  Future<void> loadExpenses() async {
    try {
      viewState.value = ViewState.loading;
      final userId = _authRepository.getCurrentUserId();

      if (userId == null) {
        throw const AppException(
          kind: AppErrorKind.unauthorized,
          userMessage: 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
        );
      }

      final result = await _expenseRepository.getExpenses(userId);

      if (result.isStale) {
        expenses.value = result.expenses;
        errorMessage.value = result.error?.userMessage ??
            'Bağlantı yok. Gösterilen veriler güncel olmayabilir.';
        viewState.value = ViewState.stale;
        if (result.error != null) {
          logAppException('ExpenseController.loadExpenses.stale', result.error!);
        }
        _clampPage();
        return;
      }

      if (result.expenses.isEmpty) {
        expenses.clear();
        viewState.value = ViewState.empty;
      } else {
        expenses.value = result.expenses;
        viewState.value = ViewState.success;
      }
      _clampPage();
    } catch (e) {
      final error = e is AppException
          ? e
          : AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
              cause: e,
            );
      logAppException('ExpenseController.loadExpenses', error);
      errorMessage.value = error.userMessage;
      viewState.value = ViewState.error;
    }
  }

  Future<void> saveExpense({
    String? existingId,
    required String amountText,
    required AppCurrency currency,
    required String category,
    required DateTime date,
    required String description,
    TransactionKind kind = TransactionKind.expense,
  }) async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;

      final cleanAmountText = amountText.trim().replaceAll(',', '.');
      if (cleanAmountText.isEmpty) {
        throw const AppException(
          kind: AppErrorKind.validation,
          userMessage: 'Lütfen bir tutar girin.',
        );
      }

      final amount = double.tryParse(cleanAmountText);
      if (amount == null) {
        throw const AppException(
          kind: AppErrorKind.validation,
          userMessage: 'Geçerli bir tutar girin.',
        );
      }
      if (amount <= 0) {
        throw const AppException(
          kind: AppErrorKind.validation,
          userMessage: 'Tutar sıfır veya negatif olamaz.',
        );
      }
      if (amount < 0.01) {
        throw const AppException(
          kind: AppErrorKind.validation,
          userMessage: 'Tutar en az 0,01 olmalıdır.',
        );
      }

      if (category.trim().isEmpty) {
        throw const AppException(
          kind: AppErrorKind.validation,
          userMessage: 'Lütfen bir kategori seçin.',
        );
      }

      final userId = _authRepository.getCurrentUserId();
      if (userId == null) {
        throw const AppException(
          kind: AppErrorKind.unauthorized,
          userMessage: 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
        );
      }

      final expense = Expense(
        id: existingId ?? '',
        userId: userId,
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        description: description,
        kind: kind,
      );

      if (existingId == null || existingId.isEmpty) {
        await _expenseRepository.addExpense(expense);
      } else {
        await _expenseRepository.updateExpense(expense);
      }

      await loadExpenses();
      _refreshBudgetsIfPresent();
      if (kind == TransactionKind.expense) {
        // Fire-and-forget: budget over-limit local alert if enabled.
        // ignore: unawaited_futures
        BudgetAlertCoordinator.tryFind()?.checkCurrentMonth();
      }
      Get.back();
      final l10n = l10nOf();
      Get.snackbar(
        l10n.saved,
        kind == TransactionKind.income ? l10n.incomeSaved : l10n.expenseSaved,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final error = e is AppException
          ? e
          : const AppException(
              kind: AppErrorKind.validation,
              userMessage: 'Lütfen geçerli bir tutar girin.',
            );
      logAppException('ExpenseController.saveExpense', error);
      Get.snackbar(l10nOf().error, error.userMessage,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  /// Returns `true` only when the remote delete succeeded.
  Future<bool> deleteExpense(String id) async {
    try {
      await _expenseRepository.deleteExpense(id);
      await loadExpenses();
      _refreshBudgetsIfPresent();
      return true;
    } catch (e) {
      final error = e is AppException
          ? e
          : AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Silme işlemi başarısız. Lütfen tekrar deneyin.',
              cause: e,
            );
      logAppException('ExpenseController.deleteExpense', error);
      Get.snackbar(l10nOf().error, error.userMessage,
          snackPosition: SnackPosition.BOTTOM);
      await loadExpenses();
      return false;
    }
  }
}
