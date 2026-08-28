// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get language => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get languagePageTitle => 'Dil';

  @override
  String get languagePageSubtitle => 'Uygulama arayüz dili';

  @override
  String get settingsTitle => 'Profil ve ayarlar';

  @override
  String get sectionAccount => 'Hesap';

  @override
  String get sectionBudget => 'Bütçe';

  @override
  String get sectionNotifications => 'Bildirimler';

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get sectionLanguage => 'Dil';

  @override
  String get userLabel => 'Kullanıcı';

  @override
  String get noSessionInfo => 'Oturum bilgisi yok';

  @override
  String get monthlyBudget => 'Aylık bütçe';

  @override
  String get monthlyBudgetSubtitle => 'Genel veya kategori limitlerini yönet';

  @override
  String get remindersAndAlerts => 'Hatırlatıcı ve uyarılar';

  @override
  String get remindersAndAlertsSubtitle => 'Günlük hatırlatıcı, bütçe limiti';

  @override
  String get darkTheme => 'Koyu tema';

  @override
  String get darkThemeOn => 'Koyu tema açık';

  @override
  String get lightThemeOn => 'Açık tema açık';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get logoutConfirmTitle =>
      'Oturumu sonlandırmak istediğinize emin misiniz?';

  @override
  String get logoutConfirmBody =>
      'Oturumunuz kapatılacak. Devam etmek istiyor musunuz?';

  @override
  String get logoutConfirmAction => 'Oturumu sonlandır';

  @override
  String get dialogClose => 'Kapat';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get loggingOut => 'Çıkış yapılıyor…';

  @override
  String get logoutHint => 'Çıkış sonrası giriş ekranına yönlendirilirsin.';

  @override
  String get authLoginSubtitle =>
      'Hesabına giriş yap ve harcamalarını takip et.';

  @override
  String get authRegisterSubtitle => 'Yeni hesap oluşturarak hemen başla.';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get switchToRegister => 'Hesabın yok mu? Kayıt ol';

  @override
  String get switchToLogin => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get transactionsTitle => 'Hareketlerim';

  @override
  String get tooltipBudget => 'Bütçe';

  @override
  String get tooltipSettings => 'Profil ve ayarlar';

  @override
  String get noRecordsYet => 'Henüz kayıt yok';

  @override
  String get noRecordsHint => 'İlk gelir veya giderini ekleyerek takibe başla.';

  @override
  String get addRecord => 'Kayıt Ekle';

  @override
  String get add => 'Ekle';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get netTotalLabel => 'Net (gelir − gider)';

  @override
  String get income => 'Gelir';

  @override
  String get expense => 'Gider';

  @override
  String get kindAll => 'Tür: Tümü';

  @override
  String get currencyAll => 'PB: Tümü';

  @override
  String recordsCount(int count) {
    return '$count kayıt';
  }

  @override
  String get noFilterMatches => 'Filtrelere uyan kayıt yok.';

  @override
  String get noCurrencyMatches => 'Bu para biriminde kayıt yok.';

  @override
  String get deleteExpenseTitle => 'Harcamayı sil';

  @override
  String deleteExpenseBody(String category, String currency) {
    return '\"$category\" ($currency) kaydını silmek istediğine emin misin?';
  }

  @override
  String get deleted => 'Silindi';

  @override
  String get expenseDeleted => 'Harcama başarıyla silindi.';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get incomeSaved => 'Gelir başarıyla kaydedildi.';

  @override
  String get expenseSaved => 'Gider başarıyla kaydedildi.';

  @override
  String get error => 'Hata';

  @override
  String get editIncome => 'Geliri Düzenle';

  @override
  String get editExpense => 'Gideri Düzenle';

  @override
  String get newIncome => 'Yeni Gelir';

  @override
  String get newExpense => 'Yeni Gider';

  @override
  String get typeLabel => 'Tür';

  @override
  String get amount => 'Tutar';

  @override
  String get currency => 'Para birimi';

  @override
  String get category => 'Kategori';

  @override
  String get descriptionOptional => 'Açıklama (opsiyonel)';

  @override
  String get date => 'Tarih';

  @override
  String get update => 'Güncelle';

  @override
  String get save => 'Kaydet';

  @override
  String get saving => 'Kaydediliyor…';

  @override
  String get budgetsTitle => 'Bütçe';

  @override
  String get addBudget => 'Bütçe ekle';

  @override
  String get noBudgetsThisMonth =>
      'Bu ay için bütçe yok.\nGenel veya kategori limiti ekleyebilirsin.';

  @override
  String get overallBudget => 'Genel (tüm giderler)';

  @override
  String get overall => 'Genel';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get sectionReminders => 'Hatırlatıcılar';

  @override
  String get dailyReminder => 'Günlük hatırlatıcı';

  @override
  String everyDayAt(String time) {
    return 'Her gün $time';
  }

  @override
  String get off => 'Kapalı';

  @override
  String get hour => 'Saat';

  @override
  String get budgetOverAlert => 'Limit aşımı uyarısı';

  @override
  String get budgetOverAlertSubtitle => 'Aylık bütçe aşıldığında bildir';

  @override
  String get sectionTest => 'Test';

  @override
  String get sendTestNotification => 'Test bildirimi gönder';

  @override
  String get testNotificationSubtitle => 'İzin ve kanal kurulumunu doğrula';

  @override
  String get testNotificationLimited => 'Bu platformda sınırlı destek';

  @override
  String get notificationsFooter =>
      'Yerel bildirimler cihazında çalışır. Uzak push (FCM) bu fazda yok; web’de destek kısıtlı olabilir.';

  @override
  String get permissionRequired => 'İzin gerekli';

  @override
  String get notificationPermissionDenied =>
      'Bildirim izni verilmedi. Sistem ayarlarından açabilirsin.';

  @override
  String get forgotPasswordTitle => 'Şifremi unuttum';

  @override
  String get resetPasswordTitle => 'Şifre sıfırla';

  @override
  String get searchHint => 'Ara (kategori, açıklama…)';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String get staleDataMessage =>
      'Bağlantı yok. Gösterilen veriler güncel olmayabilir.';

  @override
  String get filters => 'Filtreler';

  @override
  String filtersActive(int count) {
    return 'Filtreler ($count)';
  }

  @override
  String get showChart => 'Grafiği göster';

  @override
  String get hideChart => 'Grafiği gizle';

  @override
  String get dateRange => 'Tarih aralığı';

  @override
  String get sortLabel => 'Sıralama';

  @override
  String get sortDateNewest => 'Yeni → eski';

  @override
  String get sortDateOldest => 'Eski → yeni';

  @override
  String get sortAmountHigh => 'Tutar ↓';

  @override
  String get sortAmountLow => 'Tutar ↑';

  @override
  String get applyFilters => 'Uygula';

  @override
  String get connectionErrorTitle => 'Bağlantı sorunu';

  @override
  String get sessionExpiredTitle => 'Oturum sona erdi';

  @override
  String get sessionExpiredBody =>
      'Güvenliğiniz için çıkış yapıldı. Lütfen tekrar giriş yapın.';

  @override
  String get fxRatesHint => 'Toplamlar sabit kurlarla TRY’ye çevrilir';

  @override
  String budgetSpent(String amount) {
    return 'Harcanan $amount';
  }

  @override
  String budgetLimit(String amount) {
    return 'Limit $amount';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Limit aşıldı ($amount fazla)';
  }

  @override
  String budgetRemaining(String amount) {
    return 'Kalan $amount';
  }

  @override
  String get budgetDuplicateCategoryMonth =>
      'Bu kategori ve ay için zaten bir bütçe var.';

  @override
  String get chartByCategory => 'Kategorilere göre';

  @override
  String get chartTotal => 'Toplam';

  @override
  String get chartEmptyHint => 'Henüz grafik oluşturmak için yeterli veri yok.';

  @override
  String get notifDailyTitle => 'Harcama hatırlatıcısı';

  @override
  String get notifDailyBody => 'Bugünkü gelir/giderlerini kaydetmeyi unutma.';

  @override
  String get notifBudgetTitle => 'Bütçe limiti aşıldı';

  @override
  String get notifTestTitle => 'Test bildirimi';

  @override
  String get notifTestBody => 'Bildirimler çalışıyor.';

  @override
  String get notifUnsupported => 'Bu platformda yerel bildirim desteklenmiyor.';

  @override
  String get notifLabel => 'Bildirim';

  @override
  String get adminSection => 'Yönetim';

  @override
  String get adminPanelTitle => 'Yönetim Paneli';

  @override
  String get adminPanelSubtitle =>
      'Harcama veya finansal detay içermeyen operasyonel özet.';

  @override
  String get adminUserCountLabel => 'Toplam kullanıcı';

  @override
  String get adminUsersCardTitle => 'Kullanıcılar';

  @override
  String adminUsersAdminsLine(int count) {
    return 'Yönetici: $count';
  }

  @override
  String get adminManageUsersAction => 'Kullanıcı ekle ve sil';

  @override
  String get adminManageRolesAction => 'Roller ve yetkiler';

  @override
  String get adminUsersPageTitle => 'Kullanıcılar';

  @override
  String get adminRolesPageTitle => 'Roller ve yetkiler';

  @override
  String get adminUserDetailTitle => 'Kullanıcı detayı';

  @override
  String get adminEmailAddress => 'E-posta adresi';

  @override
  String get adminRoleLabel => 'Rol';

  @override
  String get adminRoleUser => 'Kullanıcı';

  @override
  String get adminRoleAdmin => 'Yönetici';

  @override
  String get adminAddUser => 'Kullanıcı ekle';

  @override
  String get adminFullName => 'Ad soyad';

  @override
  String get adminDeleteUser => 'Kullanıcıyı sil';

  @override
  String get adminDeleteUserTitle =>
      'Kullanıcıyı silmek istediğinize emin misiniz?';

  @override
  String get adminDeleteUserBody =>
      'Bu işlem geri alınamaz. Kullanıcının oturumu kapanır.';

  @override
  String get adminUserCreated => 'Kullanıcı eklendi.';

  @override
  String get adminUserDeleted => 'Kullanıcı silindi.';

  @override
  String get adminRoleUpdated => 'Rol güncellendi.';

  @override
  String get adminUnnamedUser => 'Adsız kullanıcı';

  @override
  String get adminNoUsers => 'Kayıtlı kullanıcı yok.';

  @override
  String get adminChangeRole => 'Rolü kaydet';

  @override
  String get adminSystemStatus => 'Sistem durumu';

  @override
  String get adminSystemOnline => 'API bağlantısı aktif';

  @override
  String get adminSystemOffline => 'API bağlantısı yok';

  @override
  String get adminOverviewLoadFailed =>
      'Özet yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get adminPortalSignIn => 'Yönetici paneli';

  @override
  String adminUserCountValue(int count) {
    return '$count kullanıcı';
  }

  @override
  String get adminUsageSummary => 'Kullanım özeti';

  @override
  String adminUsageAccounts(int count) {
    return '$count kayıtlı hesap';
  }

  @override
  String adminUsageAdmins(int count) {
    return '$count yönetici hesabı';
  }

  @override
  String get adminUsageEmptyHint => 'Gösterilecek operasyonel kayıt yok.';

  @override
  String get adminQuickAccess => 'Hızlı erişim';

  @override
  String get adminOpenTransactions => 'Hareketler';

  @override
  String get adminOpenBudgets => 'Bütçe';

  @override
  String get adminOpenSettings => 'Ayarlar';

  @override
  String get adminPanelEntryTitle => 'Yönetici paneli';

  @override
  String get adminPanelEntrySubtitle => 'Sistem durumu ve operasyonel özet';

  @override
  String pageNumber(int page) {
    return '$page';
  }
}
