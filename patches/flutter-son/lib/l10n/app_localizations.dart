import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem dili'**
  String get languageSystem;

  /// No description provided for @languagePageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languagePageTitle;

  /// No description provided for @languagePageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama arayüz dili'**
  String get languagePageSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil ve ayarlar'**
  String get settingsTitle;

  /// No description provided for @sectionAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get sectionAccount;

  /// No description provided for @sectionBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get sectionBudget;

  /// No description provided for @sectionNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get sectionNotifications;

  /// No description provided for @sectionAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get sectionLanguage;

  /// No description provided for @userLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get userLabel;

  /// No description provided for @noSessionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bilgisi yok'**
  String get noSessionInfo;

  /// No description provided for @monthlyBudget.
  ///
  /// In tr, this message translates to:
  /// **'Aylık bütçe'**
  String get monthlyBudget;

  /// No description provided for @monthlyBudgetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Genel veya kategori limitlerini yönet'**
  String get monthlyBudgetSubtitle;

  /// No description provided for @remindersAndAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı ve uyarılar'**
  String get remindersAndAlerts;

  /// No description provided for @remindersAndAlertsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük hatırlatıcı, bütçe limiti'**
  String get remindersAndAlertsSubtitle;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu tema'**
  String get darkTheme;

  /// No description provided for @darkThemeOn.
  ///
  /// In tr, this message translates to:
  /// **'Koyu tema açık'**
  String get darkThemeOn;

  /// No description provided for @lightThemeOn.
  ///
  /// In tr, this message translates to:
  /// **'Açık tema açık'**
  String get lightThemeOn;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu sonlandırmak istediğinize emin misiniz?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuz kapatılacak. Devam etmek istiyor musunuz?'**
  String get logoutConfirmBody;

  /// No description provided for @logoutConfirmAction.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu sonlandır'**
  String get logoutConfirmAction;

  /// No description provided for @dialogClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get dialogClose;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @loggingOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılıyor…'**
  String get loggingOut;

  /// No description provided for @logoutHint.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış sonrası giriş ekranına yönlendirilirsin.'**
  String get logoutHint;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabına giriş yap ve harcamalarını takip et.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni hesap oluşturarak hemen başla.'**
  String get authRegisterSubtitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @switchToRegister.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş yap'**
  String get switchToLogin;

  /// No description provided for @transactionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hareketlerim'**
  String get transactionsTitle;

  /// No description provided for @tooltipBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get tooltipBudget;

  /// No description provided for @tooltipSettings.
  ///
  /// In tr, this message translates to:
  /// **'Profil ve ayarlar'**
  String get tooltipSettings;

  /// No description provided for @noRecordsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get noRecordsYet;

  /// No description provided for @noRecordsHint.
  ///
  /// In tr, this message translates to:
  /// **'İlk gelir veya giderini ekleyerek takibe başla.'**
  String get noRecordsHint;

  /// No description provided for @addRecord.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ekle'**
  String get addRecord;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @netTotalLabel.
  ///
  /// In tr, this message translates to:
  /// **'Net (gelir − gider)'**
  String get netTotalLabel;

  /// No description provided for @income.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get expense;

  /// No description provided for @kindAll.
  ///
  /// In tr, this message translates to:
  /// **'Tür: Tümü'**
  String get kindAll;

  /// No description provided for @currencyAll.
  ///
  /// In tr, this message translates to:
  /// **'PB: Tümü'**
  String get currencyAll;

  /// No description provided for @recordsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt'**
  String recordsCount(int count);

  /// No description provided for @noFilterMatches.
  ///
  /// In tr, this message translates to:
  /// **'Filtrelere uyan kayıt yok.'**
  String get noFilterMatches;

  /// No description provided for @noCurrencyMatches.
  ///
  /// In tr, this message translates to:
  /// **'Bu para biriminde kayıt yok.'**
  String get noCurrencyMatches;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı sil'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseBody.
  ///
  /// In tr, this message translates to:
  /// **'\"{category}\" ({currency}) kaydını silmek istediğine emin misin?'**
  String deleteExpenseBody(String category, String currency);

  /// No description provided for @deleted.
  ///
  /// In tr, this message translates to:
  /// **'Silindi'**
  String get deleted;

  /// No description provided for @expenseDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Harcama başarıyla silindi.'**
  String get expenseDeleted;

  /// No description provided for @saved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get saved;

  /// No description provided for @incomeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Gelir başarıyla kaydedildi.'**
  String get incomeSaved;

  /// No description provided for @expenseSaved.
  ///
  /// In tr, this message translates to:
  /// **'Gider başarıyla kaydedildi.'**
  String get expenseSaved;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @editIncome.
  ///
  /// In tr, this message translates to:
  /// **'Geliri Düzenle'**
  String get editIncome;

  /// No description provided for @editExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gideri Düzenle'**
  String get editExpense;

  /// No description provided for @newIncome.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gelir'**
  String get newIncome;

  /// No description provided for @newExpense.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gider'**
  String get newExpense;

  /// No description provided for @typeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get typeLabel;

  /// No description provided for @amount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In tr, this message translates to:
  /// **'Para birimi'**
  String get currency;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @descriptionOptional.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (opsiyonel)'**
  String get descriptionOptional;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor…'**
  String get saving;

  /// No description provided for @budgetsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get budgetsTitle;

  /// No description provided for @addBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe ekle'**
  String get addBudget;

  /// No description provided for @noBudgetsThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için bütçe yok.\nGenel veya kategori limiti ekleyebilirsin.'**
  String get noBudgetsThisMonth;

  /// No description provided for @overallBudget.
  ///
  /// In tr, this message translates to:
  /// **'Genel (tüm giderler)'**
  String get overallBudget;

  /// No description provided for @overall.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get overall;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @sectionReminders.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcılar'**
  String get sectionReminders;

  /// No description provided for @dailyReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük hatırlatıcı'**
  String get dailyReminder;

  /// No description provided for @everyDayAt.
  ///
  /// In tr, this message translates to:
  /// **'Her gün {time}'**
  String everyDayAt(String time);

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @hour.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get hour;

  /// No description provided for @budgetOverAlert.
  ///
  /// In tr, this message translates to:
  /// **'Limit aşımı uyarısı'**
  String get budgetOverAlert;

  /// No description provided for @budgetOverAlertSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık bütçe aşıldığında bildir'**
  String get budgetOverAlertSubtitle;

  /// No description provided for @sectionTest.
  ///
  /// In tr, this message translates to:
  /// **'Test'**
  String get sectionTest;

  /// No description provided for @sendTestNotification.
  ///
  /// In tr, this message translates to:
  /// **'Test bildirimi gönder'**
  String get sendTestNotification;

  /// No description provided for @testNotificationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzin ve kanal kurulumunu doğrula'**
  String get testNotificationSubtitle;

  /// No description provided for @testNotificationLimited.
  ///
  /// In tr, this message translates to:
  /// **'Bu platformda sınırlı destek'**
  String get testNotificationLimited;

  /// No description provided for @notificationsFooter.
  ///
  /// In tr, this message translates to:
  /// **'Yerel bildirimler cihazında çalışır. Uzak push (FCM) bu fazda yok; web’de destek kısıtlı olabilir.'**
  String get notificationsFooter;

  /// No description provided for @permissionRequired.
  ///
  /// In tr, this message translates to:
  /// **'İzin gerekli'**
  String get permissionRequired;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi. Sistem ayarlarından açabilirsin.'**
  String get notificationPermissionDenied;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırla'**
  String get resetPasswordTitle;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara (kategori, açıklama…)'**
  String get searchHint;

  /// No description provided for @clearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get clearFilters;

  /// No description provided for @staleDataMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok. Gösterilen veriler güncel olmayabilir.'**
  String get staleDataMessage;

  /// No description provided for @filters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filters;

  /// No description provided for @filtersActive.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler ({count})'**
  String filtersActive(int count);

  /// No description provided for @showChart.
  ///
  /// In tr, this message translates to:
  /// **'Grafiği göster'**
  String get showChart;

  /// No description provided for @hideChart.
  ///
  /// In tr, this message translates to:
  /// **'Grafiği gizle'**
  String get hideChart;

  /// No description provided for @dateRange.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı'**
  String get dateRange;

  /// No description provided for @sortLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sortLabel;

  /// No description provided for @sortDateNewest.
  ///
  /// In tr, this message translates to:
  /// **'Yeni → eski'**
  String get sortDateNewest;

  /// No description provided for @sortDateOldest.
  ///
  /// In tr, this message translates to:
  /// **'Eski → yeni'**
  String get sortDateOldest;

  /// No description provided for @sortAmountHigh.
  ///
  /// In tr, this message translates to:
  /// **'Tutar ↓'**
  String get sortAmountHigh;

  /// No description provided for @sortAmountLow.
  ///
  /// In tr, this message translates to:
  /// **'Tutar ↑'**
  String get sortAmountLow;

  /// No description provided for @applyFilters.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get applyFilters;

  /// No description provided for @connectionErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı sorunu'**
  String get connectionErrorTitle;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturum sona erdi'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredBody.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğiniz için çıkış yapıldı. Lütfen tekrar giriş yapın.'**
  String get sessionExpiredBody;

  /// No description provided for @fxRatesHint.
  ///
  /// In tr, this message translates to:
  /// **'Toplamlar sabit kurlarla TRY’ye çevrilir'**
  String get fxRatesHint;

  /// No description provided for @budgetSpent.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan {amount}'**
  String budgetSpent(String amount);

  /// No description provided for @budgetLimit.
  ///
  /// In tr, this message translates to:
  /// **'Limit {amount}'**
  String budgetLimit(String amount);

  /// No description provided for @budgetOverBy.
  ///
  /// In tr, this message translates to:
  /// **'Limit aşıldı ({amount} fazla)'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan {amount}'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetDuplicateCategoryMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategori ve ay için zaten bir bütçe var.'**
  String get budgetDuplicateCategoryMonth;

  /// No description provided for @chartByCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategorilere göre'**
  String get chartByCategory;

  /// No description provided for @chartTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get chartTotal;

  /// No description provided for @chartEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Henüz grafik oluşturmak için yeterli veri yok.'**
  String get chartEmptyHint;

  /// No description provided for @notifDailyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama hatırlatıcısı'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü gelir/giderlerini kaydetmeyi unutma.'**
  String get notifDailyBody;

  /// No description provided for @notifBudgetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe limiti aşıldı'**
  String get notifBudgetTitle;

  /// No description provided for @notifTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Test bildirimi'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler çalışıyor.'**
  String get notifTestBody;

  /// No description provided for @notifUnsupported.
  ///
  /// In tr, this message translates to:
  /// **'Bu platformda yerel bildirim desteklenmiyor.'**
  String get notifUnsupported;

  /// No description provided for @notifLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim'**
  String get notifLabel;

  /// No description provided for @adminSection.
  ///
  /// In tr, this message translates to:
  /// **'Yönetim'**
  String get adminSection;

  /// No description provided for @adminPanelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetim Paneli'**
  String get adminPanelTitle;

  /// No description provided for @adminPanelSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama veya finansal detay içermeyen operasyonel özet.'**
  String get adminPanelSubtitle;

  /// No description provided for @adminUserCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Toplam kullanıcı'**
  String get adminUserCountLabel;

  /// No description provided for @adminUsersCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get adminUsersCardTitle;

  /// No description provided for @adminUsersAdminsLine.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici: {count}'**
  String adminUsersAdminsLine(int count);

  /// No description provided for @adminManageUsersAction.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı ekle ve sil'**
  String get adminManageUsersAction;

  /// No description provided for @adminManageRolesAction.
  ///
  /// In tr, this message translates to:
  /// **'Roller ve yetkiler'**
  String get adminManageRolesAction;

  /// No description provided for @adminUsersPageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get adminUsersPageTitle;

  /// No description provided for @adminRolesPageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Roller ve yetkiler'**
  String get adminRolesPageTitle;

  /// No description provided for @adminUserDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı detayı'**
  String get adminUserDetailTitle;

  /// No description provided for @adminEmailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi'**
  String get adminEmailAddress;

  /// No description provided for @adminRoleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get adminRoleLabel;

  /// No description provided for @adminRoleUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get adminRoleUser;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get adminRoleAdmin;

  /// No description provided for @adminAddUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı ekle'**
  String get adminAddUser;

  /// No description provided for @adminFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad'**
  String get adminFullName;

  /// No description provided for @adminDeleteUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıyı sil'**
  String get adminDeleteUser;

  /// No description provided for @adminDeleteUserTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıyı silmek istediğinize emin misiniz?'**
  String get adminDeleteUserTitle;

  /// No description provided for @adminDeleteUserBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Kullanıcının oturumu kapanır.'**
  String get adminDeleteUserBody;

  /// No description provided for @adminUserCreated.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı eklendi.'**
  String get adminUserCreated;

  /// No description provided for @adminUserDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı silindi.'**
  String get adminUserDeleted;

  /// No description provided for @adminRoleUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Rol güncellendi.'**
  String get adminRoleUpdated;

  /// No description provided for @adminUnnamedUser.
  ///
  /// In tr, this message translates to:
  /// **'Adsız kullanıcı'**
  String get adminUnnamedUser;

  /// No description provided for @adminNoUsers.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kullanıcı yok.'**
  String get adminNoUsers;

  /// No description provided for @adminChangeRole.
  ///
  /// In tr, this message translates to:
  /// **'Rolü kaydet'**
  String get adminChangeRole;

  /// No description provided for @adminSystemStatus.
  ///
  /// In tr, this message translates to:
  /// **'Sistem durumu'**
  String get adminSystemStatus;

  /// No description provided for @adminSystemOnline.
  ///
  /// In tr, this message translates to:
  /// **'API bağlantısı aktif'**
  String get adminSystemOnline;

  /// No description provided for @adminSystemOffline.
  ///
  /// In tr, this message translates to:
  /// **'API bağlantısı yok'**
  String get adminSystemOffline;

  /// No description provided for @adminOverviewLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Özet yüklenemedi. Lütfen tekrar deneyin.'**
  String get adminOverviewLoadFailed;

  /// No description provided for @adminPortalSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici paneli'**
  String get adminPortalSignIn;

  /// No description provided for @adminUserCountValue.
  ///
  /// In tr, this message translates to:
  /// **'{count} kullanıcı'**
  String adminUserCountValue(int count);

  /// No description provided for @adminUsageSummary.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım özeti'**
  String get adminUsageSummary;

  /// No description provided for @adminUsageAccounts.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıtlı hesap'**
  String adminUsageAccounts(int count);

  /// No description provided for @adminUsageAdmins.
  ///
  /// In tr, this message translates to:
  /// **'{count} yönetici hesabı'**
  String adminUsageAdmins(int count);

  /// No description provided for @adminUsageEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek operasyonel kayıt yok.'**
  String get adminUsageEmptyHint;

  /// No description provided for @adminQuickAccess.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı erişim'**
  String get adminQuickAccess;

  /// No description provided for @adminOpenTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Hareketler'**
  String get adminOpenTransactions;

  /// No description provided for @adminOpenBudgets.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get adminOpenBudgets;

  /// No description provided for @adminOpenSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get adminOpenSettings;

  /// No description provided for @adminPanelEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici paneli'**
  String get adminPanelEntryTitle;

  /// No description provided for @adminPanelEntrySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem durumu ve operasyonel özet'**
  String get adminPanelEntrySubtitle;

  /// No description provided for @pageNumber.
  ///
  /// In tr, this message translates to:
  /// **'{page}'**
  String pageNumber(int page);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
