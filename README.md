ExpenseTracker API (Backend)
Bu proje, harcama takip uygulamasının veri ve kimlik yönetimi katmanını Firebase'den ayrıştırarak .NET 8 altyapısına taşıyan Web API projesidir.

Teknik Mimarisi ve Özellikler
Altyapı: ASP.NET Core 8 Web API.

Veritabanı: PostgreSQL (Entity Framework Core ile yönetilmektedir).

Güvenlik:

Parola koruması için BCrypt algoritması ile hashing.

Kimlik doğrulama için JWT (JSON Web Token) tabanlı yetkilendirme.

Yapı: Katmanlı mimari prensiplerine uygun olarak oluşturulmuş Controller ve servis yapıları.

Kurulum ve Çalıştırma
Repoyu bilgisayarınıza klonlayın.

PostgreSQL veritabanınızı hazırlayın ve appsettings.json içerisindeki DefaultConnection dizesini kendi veritabanı bilgilerinizle güncelleyin.

Projeyi derleyin ve çalıştırın.

Swagger arayüzü (/swagger) üzerinden API uç noktalarını (Register/Login) test edebilirsiniz.

ExpenseTracker Mobile (Flutter)
Bu uygulama, harcama takibi yapan ve verilerini .NET tabanlı uzak bir API'den çeken bir Flutter projesidir.

Uygulama Mimarisi
API Entegrasyonu: IExpenseRepository ve IAuthRepository arayüzleri kullanılarak, uygulama mantığı Firebase'den API tabanlı bir sisteme taşınmıştır.

Güvenlik: Giriş sonrası alınan JWT token'lar, yüksek güvenlikli flutter_secure_storage içerisinde saklanmaktadır.

Mimari: Uygulama, uzak veri kaynağı (API) ve yerel önbellek (Hive) ayrımını koruyarak, ekranlara (UI) dokunmadan veri kaynağı değişikliğine olanak tanıyacak şekilde modüler tasarlanmıştır.

Başlıca Özellikler
Tam güvenli JWT kimlik doğrulama akışı.

Kullanıcıya özel harcama listeleme, ekleme ve yönetim.

Token süresi dolduğunda otomatik oturum sonlandırma yeteneği.
