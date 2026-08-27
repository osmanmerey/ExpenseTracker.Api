// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get language => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'System language';

  @override
  String get languagePageTitle => 'Language';

  @override
  String get languagePageSubtitle => 'App interface language';

  @override
  String get settingsTitle => 'Profile & settings';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionBudget => 'Budget';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get userLabel => 'User';

  @override
  String get noSessionInfo => 'No session info';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get monthlyBudgetSubtitle => 'Manage overall or category limits';

  @override
  String get remindersAndAlerts => 'Reminders & alerts';

  @override
  String get remindersAndAlertsSubtitle => 'Daily reminder, budget limits';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get darkThemeOn => 'Dark theme on';

  @override
  String get lightThemeOn => 'Light theme on';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmBody => 'Your session will end. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get loggingOut => 'Logging out…';

  @override
  String get logoutHint =>
      'After logout you will return to the sign-in screen.';

  @override
  String get authLoginSubtitle => 'Sign in to track your spending.';

  @override
  String get authRegisterSubtitle => 'Create an account to get started.';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get switchToRegister => 'No account? Sign up';

  @override
  String get switchToLogin => 'Already have an account? Sign in';

  @override
  String get transactionsTitle => 'My activity';

  @override
  String get tooltipBudget => 'Budget';

  @override
  String get tooltipSettings => 'Profile & settings';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get noRecordsHint =>
      'Add your first income or expense to start tracking.';

  @override
  String get addRecord => 'Add record';

  @override
  String get add => 'Add';

  @override
  String get retry => 'Try again';

  @override
  String get netTotalLabel => 'Net (income − expense)';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get kindAll => 'Type: All';

  @override
  String get currencyAll => 'FX: All';

  @override
  String recordsCount(int count) {
    return '$count records';
  }

  @override
  String get noFilterMatches => 'No records match the filters.';

  @override
  String get noCurrencyMatches => 'No records for this currency.';

  @override
  String get deleteExpenseTitle => 'Delete expense';

  @override
  String deleteExpenseBody(String category, String currency) {
    return 'Delete \"$category\" ($currency)?';
  }

  @override
  String get deleted => 'Deleted';

  @override
  String get expenseDeleted => 'Expense deleted.';

  @override
  String get saved => 'Saved';

  @override
  String get incomeSaved => 'Income saved.';

  @override
  String get expenseSaved => 'Expense saved.';

  @override
  String get error => 'Error';

  @override
  String get editIncome => 'Edit income';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get newIncome => 'New income';

  @override
  String get newExpense => 'New expense';

  @override
  String get typeLabel => 'Type';

  @override
  String get amount => 'Amount';

  @override
  String get currency => 'Currency';

  @override
  String get category => 'Category';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get date => 'Date';

  @override
  String get update => 'Update';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get budgetsTitle => 'Budget';

  @override
  String get addBudget => 'Add budget';

  @override
  String get noBudgetsThisMonth =>
      'No budgets for this month.\nAdd an overall or category limit.';

  @override
  String get overallBudget => 'Overall (all expenses)';

  @override
  String get overall => 'Overall';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String everyDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get off => 'Off';

  @override
  String get hour => 'Time';

  @override
  String get budgetOverAlert => 'Over-budget alert';

  @override
  String get budgetOverAlertSubtitle =>
      'Notify when a monthly budget is exceeded';

  @override
  String get sectionTest => 'Test';

  @override
  String get sendTestNotification => 'Send test notification';

  @override
  String get testNotificationSubtitle => 'Verify permission and channel setup';

  @override
  String get testNotificationLimited => 'Limited support on this platform';

  @override
  String get notificationsFooter =>
      'Local notifications run on your device. Remote push (FCM) is not in this phase; web support may be limited.';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get notificationPermissionDenied =>
      'Notification permission was denied. You can enable it in system settings.';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get searchHint => 'Search (category, description…)';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get staleDataMessage =>
      'No connection. Shown data may be out of date.';

  @override
  String get filters => 'Filters';

  @override
  String filtersActive(int count) {
    return 'Filters ($count)';
  }

  @override
  String get showChart => 'Show chart';

  @override
  String get hideChart => 'Hide chart';

  @override
  String get dateRange => 'Date range';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortDateNewest => 'Newest first';

  @override
  String get sortDateOldest => 'Oldest first';

  @override
  String get sortAmountHigh => 'Amount ↓';

  @override
  String get sortAmountLow => 'Amount ↑';

  @override
  String get applyFilters => 'Apply';

  @override
  String get connectionErrorTitle => 'Connection problem';

  @override
  String get sessionExpiredTitle => 'Session expired';

  @override
  String get sessionExpiredBody =>
      'You were signed out for security. Please sign in again.';

  @override
  String get fxRatesHint => 'Totals convert to TRY with fixed rates';

  @override
  String budgetSpent(String amount) {
    return 'Spent $amount';
  }

  @override
  String budgetLimit(String amount) {
    return 'Limit $amount';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Over budget ($amount over)';
  }

  @override
  String budgetRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get budgetDuplicateCategoryMonth =>
      'A budget already exists for this category and month.';

  @override
  String get chartByCategory => 'By category';

  @override
  String get chartTotal => 'Total';

  @override
  String get chartEmptyHint => 'Not enough data to build a chart yet.';

  @override
  String get notifDailyTitle => 'Expense reminder';

  @override
  String get notifDailyBody =>
      'Don\'t forget to log today\'s income and expenses.';

  @override
  String get notifBudgetTitle => 'Budget limit exceeded';

  @override
  String get notifTestTitle => 'Test notification';

  @override
  String get notifTestBody => 'Notifications are working.';

  @override
  String get notifUnsupported =>
      'Local notifications are not supported on this platform.';

  @override
  String get notifLabel => 'Notification';

  @override
  String get adminSection => 'Admin';

  @override
  String get adminPanelTitle => 'Admin panel';

  @override
  String get adminPanelSubtitle =>
      'Operational summary with no personal financial data.';

  @override
  String get adminUserCountLabel => 'Total users';

  @override
  String adminUserCountValue(int count) {
    return '$count users';
  }

  @override
  String get adminSystemStatus => 'System status';

  @override
  String get adminSystemOnline => 'API connection active';

  @override
  String get adminSystemOffline => 'API unavailable';

  @override
  String get adminUsageSummary => 'Usage summary';

  @override
  String adminUsageAccounts(int count) {
    return '$count registered accounts';
  }

  @override
  String adminUsageAdmins(int count) {
    return '$count admin accounts';
  }

  @override
  String get adminUsageEmptyHint => 'No operational records to show.';

  @override
  String get adminQuickAccess => 'Quick access';

  @override
  String get adminOpenTransactions => 'Activity';

  @override
  String get adminOpenBudgets => 'Budget';

  @override
  String get adminOpenSettings => 'Settings';

  @override
  String get adminPanelEntryTitle => 'Admin panel';

  @override
  String get adminPanelEntrySubtitle => 'System status and operational summary';

  @override
  String get adminOverviewLoadFailed =>
      'Could not load the overview. Please try again.';

  @override
  String get adminPortalSignIn => 'Admin panel';

  @override
  String pageNumber(int page) {
    return '$page';
  }
}
