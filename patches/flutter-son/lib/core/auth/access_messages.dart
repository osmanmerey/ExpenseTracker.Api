/// User-facing copy for permission and admin-only actions.
abstract final class AccessMessages {
  static const deniedTitle = 'Erişim yetkiniz yok';
  static const deniedBody = 'Bu sayfa yalnızca yöneticiler içindir.';
  static const lastAdmin =
      'Son yönetici hesabı kaldırılamaz. Önce başka bir yönetici atayın.';
  static const sessionExpired =
      'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';
  static const usersLoadFailed = 'Kullanıcı listesi alınamadı. Lütfen tekrar deneyin.';
  static const roleUpdateFailed = 'Rol güncellenemedi. Lütfen tekrar deneyin.';
  static const userDeleteFailed = 'Kullanıcı silinemedi. Lütfen tekrar deneyin.';
}
