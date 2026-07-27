# ExpenseTracker API

.NET 8, Entity Framework Core ve PostgreSQL ile geliştirilmiş harcama takip Web API'si.

Veritabanı: PostgreSQL (Entity Framework Core ile yönetilmektedir).

- BCrypt ile parola hashleme
- JWT Bearer kimlik doğrulama
- Kullanıcıya özel, yetkilendirilmiş harcama CRUD işlemleri
- DTO tabanlı istek/yanıt modelleri ve girdi doğrulama
- Swagger üzerinden JWT destekli API testi
- Flutter Web istemcileri için yapılandırılabilir CORS

## Kurulum

Gizli bilgiler repoda tutulmaz. Proje dizininde User Secrets yapılandırın:

```powershell
cd ExpenseTracker.Api
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Database=expense_tracker;Username=postgres;Password=<parola>"
dotnet user-secrets set "Jwt:Key" "<en-az-64-karakterlik-rastgele-bir-anahtar>"
```

Veritabanını hazırlayıp API'yi çalıştırın:

```powershell
dotnet ef database update
dotnet run
```

Development ortamında Swagger arayüzü `/swagger` adresindedir. Önce kayıt veya
giriş isteği gönderin, dönen token'ı Swagger'daki **Authorize** alanına girin.

## Veritabanı sağlayıcısı

**Varsayılan olarak PostgreSQL kullanılır** (Development dahil tüm ortamlarda).
Yukarıdaki `ConnectionStrings:DefaultConnection` User Secret'ı ayarlandığı
sürece ek bir yapılandırma gerekmez.

Dış bir PostgreSQL sunucusu kurmadan hızlıca çalıştırmak/test etmek isterseniz,
EF Core InMemory sağlayıcısına geçebilirsiniz. Bunun için `appsettings.json`
dosyalarını değiştirmeden, sadece o çalıştırma için bir ortam değişkeni
ayarlamanız yeterlidir:

```powershell
$env:Database__Provider = "InMemory"
dotnet run
```

veya tek seferlik:

```powershell
dotnet run --Database:Provider=InMemory
```

> ⚠️ InMemory modunda veriler işlem belleğinde tutulur ve her yeniden
> başlatmada silinir; ayrıca EF Core migrasyon komutları (`dotnet ef ...`)
> bu modda çalışmaz. Sadece geçici/hızlı denemeler için kullanın.

## Uç noktalar

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/users/me`
- `PUT /api/users/me`
- `DELETE /api/users/me`
- `GET /api/expenses`
- `GET /api/expenses/{id}`
- `POST /api/expenses`
- `PUT /api/expenses/{id}`
- `DELETE /api/expenses/{id}`

Expense ve kullanıcı uç noktaları JWT gerektirir. Expense kayıtlarının `UserId`
değeri token'daki kullanıcı kimliğinden sunucu tarafından atanır; istemci başka
bir kullanıcının kayıtlarını okuyamaz veya değiştiremez.

## Postman

`postman/ExpenseTracker.postman_collection.json` koleksiyonunu Postman'e import
edin. `baseUrl` koleksiyon değişkenini API adresinizle güncelleyin (varsayılan
`https://localhost:7270`). **Login** isteği başarılı olduğunda dönen token
otomatik olarak `token` değişkenine kaydedilir ve korumalı isteklerde
`Authorization: Bearer` başlığı olarak kullanılır.
