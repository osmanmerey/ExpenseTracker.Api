# ExpenseTracker API

.NET 8, Entity Framework Core ve PostgreSQL ile geliştirilmiş harcama takip Web API'si.

Veritabanı: PostgreSQL (Entity Framework Core ile yönetilmektedir). Hızlı deneme için InMemory de desteklenir.

- BCrypt ile parola hashleme
- JWT Bearer kimlik doğrulama
- Kullanıcıya özel, yetkilendirilmiş harcama ve gelir CRUD işlemleri (`TransactionKind`)
- Aylık bütçe CRUD (harcanan tutar, kalan limit, limit aşımı)
- Şifremi unuttum / şifre sıfırlama
- DTO tabanlı istek/yanıt modelleri ve girdi doğrulama
- Problem Details hata formatı ve auth rate limiting
- Swagger üzerinden JWT destekli API testi
- Flutter Web istemcileri için yapılandırılabilir CORS

## Kurulum

Gizli bilgiler repoda tutulmaz. Proje dizininde User Secrets yapılandırın.

### PostgreSQL ile çalıştırma (önerilen)

```powershell
docker compose up -d
cd ExpenseTracker.Api
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "<en-az-64-karakterlik-rastgele-bir-anahtar>"
dotnet run
```

Development ortamında varsayılan bağlantı dizesi `appsettings.Development.json` içindedir
(`Host=localhost;Database=expense_tracker;Username=postgres;Password=postgres`).
Harici bir sunucu kullanıyorsanız User Secrets ile override edin:

```powershell
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Database=expense_tracker;Username=postgres;Password=<parola>"
```

Postgres modunda uygulama açılışta EF Core migrasyonlarını uygular.
İsterseniz elle de çalıştırabilirsiniz:

```powershell
dotnet ef database update
```

Development ortamında Swagger arayüzü `/swagger` adresindedir. Önce kayıt veya
giriş isteği gönderin, dönen token'ı Swagger'daki **Authorize** alanına girin.

Health kontrolü: `GET /health`

## Veritabanı sağlayıcısı

**Varsayılan olarak PostgreSQL kullanılır** (Development dahil tüm ortamlarda).
Yukarıdaki `ConnectionStrings:DefaultConnection` ayarlandığı sürece ek bir
yapılandırma gerekmez.

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

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`

### Users
- `GET /api/users/me`
- `PUT /api/users/me`
- `DELETE /api/users/me`

### Expenses
- `GET /api/expenses`
- `GET /api/expenses/{id}`
- `POST /api/expenses`
- `PUT /api/expenses/{id}`
- `DELETE /api/expenses/{id}`

### Budgets
- `GET /api/budgets?year=&month=`
- `GET /api/budgets/{id}`
- `POST /api/budgets`
- `PUT /api/budgets/{id}`
- `DELETE /api/budgets/{id}`

Expense, budget ve kullanıcı uç noktaları JWT gerektirir. Kayıtların `UserId`
değeri token'daki kullanıcı kimliğinden sunucu tarafından atanır; istemci başka
bir kullanıcının kayıtlarını okuyamaz veya değiştiremez.

Expense isteklerinde `kind` alanı `Expense` veya `Income` olabilir.
Bütçe hesaplamasında harcamalar sabit kurlarla TRY karşılığına çevrilir.

## Test

```powershell
dotnet test
```

## Versiyonlama

Proje [Semantic Versioning](https://semver.org/lang/tr/) (`MAJOR.MINOR.PATCH`)
kullanır ve tek bir `master` dalı üzerinde ilerler (trunk-based); sürümler
branch ile değil, git **tag**'leri ve GitHub **Release**'leri ile işaretlenir.

- **MAJOR** — geriye uyumsuz (breaking) API değişikliği
- **MINOR** — geriye uyumlu yeni özellik
- **PATCH** — geriye uyumlu hata düzeltmesi / iç refactor

Yeni bir sürüm yayımlamak için:

```powershell
# 1. ExpenseTracker.Api/ExpenseTracker.Api.csproj içindeki <Version> değerini güncelleyin
# 2. CHANGELOG.md'ye yeni sürüm için bir bölüm ekleyin (Unreleased'i taşıyın)
git add -A
git commit -m "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "vX.Y.Z"
git push origin master --tags
```

Ardından GitHub'da **Releases → Draft a new release** ile bu tag'i seçip
`CHANGELOG.md`'deki ilgili bölümü açıklama olarak ekleyerek bir Release
yayımlayabilirsiniz.

Mevcut sürümler için bkz. [`CHANGELOG.md`](./CHANGELOG.md).

## Postman

`postman/ExpenseTracker.postman_collection.json` koleksiyonunu Postman'e import
edin. `baseUrl` koleksiyon değişkenini API adresinizle güncelleyin (örnek
`http://localhost:5123`). **Login** isteği başarılı olduğunda dönen token
otomatik olarak `token` değişkenine kaydedilir ve korumalı isteklerde
`Authorization: Bearer` başlığı olarak kullanılır.

## İlgili istemci

Flutter uygulaması: [expense_tracker](https://github.com/osmanmerey/expense_tracker)
