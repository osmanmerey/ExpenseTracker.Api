# ExpenseTracker – Firebase'den ASP.NET Core API'ye Geçiş Raporu

Bu belge, harcama takip uygulamasının veri ve kimlik katmanının Firebase'den
ASP.NET Core Web API + PostgreSQL altyapısına taşınmasını, yapılan değişiklikleri,
güvenlik önlemlerini ve test sonuçlarını özetler.

## İçindekiler
1. [Backend Mimarisi ve Kurulum](#1-backend-mimarisi-ve-kurulum)
2. [Veritabanı / Migration Adımları](#2-veritabanı--migration-adımları)
3. [Kimlik Doğrulama ve JWT Akışı](#3-kimlik-doğrulama-ve-jwt-akışı)
4. [Endpoint Listesi](#4-endpoint-listesi)
5. [Güvenlik Önlemleri](#5-güvenlik-önlemleri)
6. [Firebase'den API Repository'lerine Geçiş (Flutter)](#6-firebaseden-api-repositorylerine-geçiş-flutter)
7. [Ekran/Controller Değiştirmeden Yapılan DI Değişikliği](#7-ekrancontroller-değiştirmeden-yapılan-di-değişikliği)
8. [Test Sonuçları](#8-test-sonuçları)
9. [GitHub Bağlantıları](#9-github-bağlantıları)
10. [Kalan Riskler](#10-kalan-riskler)

---

## 1. Backend Mimarisi ve Kurulum

**Teknoloji:** ASP.NET Core 8 Web API, Entity Framework Core 9, PostgreSQL (Npgsql),
BCrypt.Net, JWT Bearer authentication, Swagger/Swashbuckle.

**Katmanlar:**

| Katman | Açıklama |
|--------|----------|
| `Controllers/` | `AuthController`, `ExpensesController`, `UsersController` |
| `Data/AppDbContext.cs` | EF Core DbContext (`Users`, `Expenses`) |
| `Models/` | `User`, `Expense` entity'leri |
| `DTOs/` | İstek/yanıt sözleşmeleri (entity'ler dışarı açılmaz) |
| `Migrations/` | EF Core migration geçmişi |

**Proje yapısı:**

```
ExpenseTracker.Api.sln
├── ExpenseTracker.Api/            # Web API projesi
│   ├── Controllers/
│   ├── Data/AppDbContext.cs
│   ├── Models/ (User, Expense)
│   ├── DTOs/  (UserRegisterDto, UserLoginDto, UserResponseDto, UserUpdateDto,
│   │           ExpenseCreateDto, ExpenseUpdateDto, ExpenseResponseDto)
│   ├── Migrations/
│   └── Program.cs
├── ExpenseTracker.Api.Tests/      # xUnit entegrasyon testleri
└── postman/ExpenseTracker.postman_collection.json
```

**Kurulum (gizli bilgiler kaynak kodda tutulmaz — User Secrets):**

```powershell
cd ExpenseTracker.Api
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Database=expense_tracker;Username=postgres;Password=<parola>"
dotnet user-secrets set "Jwt:Key" "<en-az-64-karakterlik-rastgele-anahtar>"
```

`Jwt:Issuer` ve `Jwt:Audience` değerleri `appsettings.json` içinde varsayılan
olarak tanımlıdır (`ExpenseTracker.Api` / `ExpenseTracker.Client`), gerekirse
override edilebilir. `Program.cs` başlangıçta bağlantı dizesi ve JWT anahtarının
varlığını/uzunluğunu doğrular; eksikse uygulama açılmaz (fail-fast).

**Derleme ve çalıştırma:**

```powershell
dotnet build ExpenseTracker.Api.sln
dotnet run --project ExpenseTracker.Api            # https://localhost:7270
```

Development ortamında Swagger arayüzü `/swagger` adresindedir ve JWT ile
**Authorize** desteği içerir.

---

## 2. Veritabanı / Migration Adımları

EF Core "code-first" migration kullanılır. Mevcut migration'lar:
`InitialCreate` ve `UpdateUserModel`.

```powershell
# EF araçları (bir defaya mahsus)
dotnet tool install --global dotnet-ef

# Veritabanını oluştur / güncelle
dotnet ef database update --project ExpenseTracker.Api

# Yeni migration ekleme
dotnet ef migrations add <MigrationAdi> --project ExpenseTracker.Api
```

**Şema:**

- `Users`: `Id (Guid, PK)`, `Name`, `Email`, `PasswordHash`
- `Expenses`: `Id (Guid, PK)`, `Title`, `Amount (decimal)`, `Date`, `Category`,
  `UserId (FK → Users.Id)`
- İlişki: `Expense → User` (many-to-one), `OnDelete: Cascade`.

> Not: Testler EF Core InMemory sağlayıcısı kullanır; gerçek PostgreSQL şeması
> migration'lar ile yönetilir.

---

## 3. Kimlik Doğrulama ve JWT Akışı

1. **Kayıt** (`POST /api/auth/register`): E-posta benzersizliği kontrol edilir,
   parola **BCrypt** ile hash'lenir, kullanıcı kaydedilir. Yanıt `201 Created`
   olup yalnızca `{ id, name, email }` döner — **PasswordHash asla dönmez.**
2. **Giriş** (`POST /api/auth/login`): Parola BCrypt ile doğrulanır. Başarılıysa
   süreli (1 gün) bir **JWT** ve `{ id, name, email }` döner.
3. **Token içeriği (claims):** yalnızca gerekli olanlar —
   `NameIdentifier = userId (Guid)` ve `Name = email`. Hassas veri (parola, hash)
   token'a konmaz.
4. **İmzalama:** HmacSha512, anahtar `Jwt:Key` (config/secret'ten).
5. **Doğrulama** (`Program.cs`): issuer, audience, lifetime ve imza anahtarı
   doğrulanır (`ClockSkew = 1 dk`).
6. **Yetkilendirme:** Korumalı controller'lar `[Authorize]` ile işaretlidir;
   `UserId` her istekte **JWT claim'inden** alınır, request body'den değil.

Akış:

```
register → (201) → login → (200, token) → Authorization: Bearer <token> → korumalı uçlar
```

---

## 4. Endpoint Listesi

| Metot | Yol | Auth | Açıklama |
|-------|-----|------|----------|
| POST | `/api/auth/register` | Hayır | Kayıt (201) |
| POST | `/api/auth/login` | Hayır | Giriş, JWT döner (200) |
| GET | `/api/expenses` | **Evet** | Oturum sahibinin harcamaları |
| GET | `/api/expenses/{id}` | **Evet** | Tek harcama (yalnızca sahibi) |
| POST | `/api/expenses` | **Evet** | Harcama oluştur (201) |
| PUT | `/api/expenses/{id}` | **Evet** | Harcama güncelle (204) |
| DELETE | `/api/expenses/{id}` | **Evet** | Harcama sil (204) |
| GET | `/api/users/me` | **Evet** | Profil bilgisi |
| PUT | `/api/users/me` | **Evet** | Profil güncelle |
| DELETE | `/api/users/me` | **Evet** | Hesabı sil |

**HTTP durum kodları:** 200/201/204 (başarı), 400 (doğrulama), 401 (yetkisiz),
404 (bulunamadı/erişim yok), 409 (çakışan e-posta).

Postman koleksiyonu: `postman/ExpenseTracker.postman_collection.json`. **Login**
isteği token'ı otomatik olarak koleksiyon değişkenine kaydeder.

---

## 5. Güvenlik Önlemleri

- **Parola güvenliği:** BCrypt ile hash; düz metin parola saklanmaz.
- **PasswordHash sızıntısı yok:** Hiçbir yanıt entity'yi doğrudan döndürmez;
  yalnızca DTO'lar döner.
- **Yetkilendirme:** Tüm harcama ve kullanıcı uçları `[Authorize]`.
- **Kullanıcı izolasyonu:** Tüm sorgular `e.UserId == <token'daki userId>` ile
  filtrelenir. Başka kullanıcının kaydına erişim `404` döner (varlık ifşa edilmez).
- **UserId kaynağı:** Yalnızca JWT claim'i; istemci body'sindeki `UserId`
  dikkate alınmaz (over-posting engellenir).
- **Sırların kod dışında tutulması:** DB bağlantısı ve `Jwt:Key` User
  Secrets/environment variable'dan okunur; repodaki `appsettings.json` boş bırakılmıştır.
- **Girdi doğrulaması:** DTO'larda `[Required]`, `[EmailAddress]`, uzunluk ve
  `[Range]` kısıtları; `[ApiController]` otomatik 400 üretir.
- **JWT sağlamlığı:** issuer/audience/lifetime doğrulaması; anahtar en az 64
  karakter (HmacSha512 gereksinimi) — başlangıçta zorlanır.
- **HTTPS:** `UseHttpsRedirection` etkin; `https` launch profili mevcut.
- **CORS:** Yalnızca yapılandırılan origin'lere izin (Flutter Web istemcileri için).
- **Token loglanmaz.**

---

## 6. Firebase'den API Repository'lerine Geçiş (Flutter)

Flutter tarafında **ekranlar ve controller'lar değiştirilmeden**, mevcut
`IAuthRepository` ve `IExpenseRepository` sözleşmeleri korunarak API tabanlı
uygulamalar eklendi.

**Eklenen dosyalar:**

| Dosya | Görev |
|-------|-------|
| `lib/core/constants/api_constants.dart` | HTTPS `baseUrl` |
| `lib/core/storage/token_storage.dart` | JWT + userId'yi **yalnızca** `flutter_secure_storage`'da saklar |
| `lib/core/network/api_client.dart` | `Authorization: Bearer <token>` ekleyen HTTP istemcisi |
| `lib/features/auth/data/repositories/api_auth_repository.dart` | `ApiAuthRepository` |
| `lib/features/expenses/data/repositories/api_expense_repository.dart` | `ApiExpenseRepository` |

**Güncellenen dosyalar:**

- `pubspec.yaml`: `http`, `flutter_secure_storage` eklendi.
- `expense_dto.dart`: API için `fromApiJson` / `toApiJson` eklendi
  (`description` ↔ API `title`, `date` ↔ ISO 8601). Hive `fromMap`/`toMap`
  **değiştirilmedi**, böylece mevcut önbellek biçimi uyumlu kaldı.

**Önemli davranışlar:**

- **Remote / local ayrımı:** Ağ iletişimi `ApiClient` + repository'lerde; Hive
  önbelleği `ApiExpenseRepository.getExpenses` içinde eski Firebase repo ile
  **birebir aynı** kutu adı (`expensesCacheBox`) ve anahtar biçimi
  (`cached_expenses_$userId`) ile korundu. Ağ hatasında önbelleğe düşülür.
- **Token depolama:** Sadece `flutter_secure_storage`. Hive/SharedPreferences'ta
  token tutulmaz. Senkron `getCurrentUserId()` sözleşmesi için bellek içi kopya
  başlangıçta `init()` ile doldurulur.
- **Register:** API register token döndürmediğinden, kayıt sonrası otomatik login
  yapılır; `name` alanı e-postadan türetilir (sözleşme `(email, password)`
  imzasını değiştirmeden).
- **HTTPS:** `baseUrl` HTTPS'tir (emülatör/cihaz için notlar dosyada mevcut).
- **Loglama:** Token veya hassas veri loglanmaz.

**Alan eşlemesi (Flutter ↔ API):**

| Flutter `Expense` | API DTO |
|-------------------|---------|
| `description` | `Title` |
| `date` (DateTime) | `Date` (ISO 8601) |
| `id` | `Id` (Guid) |
| `userId` | Yanıtta yok; sunucuda JWT claim'inden |
| `amount`, `category` | Aynı |

---

## 7. DI Değişikliği ile Veri Kaynağının Değiştirilmesi

**Firebase → API geçişinin kendisi** kapsamında Flutter tarafında yapılan
değişiklik yalnızca **veri katmanı ve bağımlılık kaydıdır**: yeni `ApiAuthRepository`
ve `ApiExpenseRepository` sınıfları ile `ApiClient`, `TokenStorage`, `ApiConstants`
altyapısı eklendi ve `lib/main.dart` içindeki DI kaydı Firebase uygulamalarından
bu API uygulamalarına çevrildi.

Bu geçiş sırasında `AuthController`, `ExpenseController` ve sayfalar (`*_page.dart`)
**API'ye bağlanmak için değiştirilmedi** — soyut `IAuthRepository` /
`IExpenseRepository` sözleşmeleri korunduğu için veri kaynağı arayüz koduna
dokunulmadan değiştirilebildi.

> Not: Depo geçmişinde bu presentation dosyalarında (ör. `auth_page.dart`,
> `expense_form_page.dart`, ilgili controller'lar) görülen değişiklikler, API
> geçişinin parçası değildir; bunlar Flutter uygulamasının **daha önceki
> geliştirme aşamasında** yapılmış işlerdir (mimari sızıntı düzeltmesi, tarih
> seçici ve ondalık klavye gibi UI iyileştirmeleri). API geçişi bu dosyaları
> değiştirmeyi gerektirmemiştir.

Önce (Firebase):

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
Get.put<IAuthRepository>(FirebaseAuthRepository());
Get.put<IExpenseRepository>(FirebaseExpenseRepository());
```

Sonra (API):

```dart
await Hive.initFlutter();

final tokenStorage = TokenStorage();
await tokenStorage.init();
Get.put<TokenStorage>(tokenStorage);
Get.put<ApiClient>(ApiClient(tokenStorage));

Get.put<IAuthRepository>(ApiAuthRepository(Get.find<ApiClient>(), Get.find<TokenStorage>()));
Get.put<IExpenseRepository>(ApiExpenseRepository(Get.find<ApiClient>()));
```

Controller kayıtları aynı imza ile korunduğu için sözleşme uyumu sayesinde
arayüz koduna dokunulmadan yalnızca veri kaynağı (Firebase → API) değişti.

---

## 8. Test Sonuçları

### Backend — `dotnet test` (xUnit + WebApplicationFactory + EF Core InMemory)

**Sonuç: 10/10 başarılı.**

Test edilen senaryolar:

| Test | Doğrulanan |
|------|------------|
| `Register_ReturnsCreated_AndDoesNotLeakPasswordHash` | 201 + yanıtta `passwordHash` yok |
| `Register_WithDuplicateEmail_ReturnsConflict` | 409 |
| `Register_WithInvalidInput_ReturnsBadRequest` | 400 |
| `Login_WithValidCredentials_ReturnsToken` | 200 + token + userId |
| `Login_WithWrongPassword_ReturnsUnauthorized` | 401 |
| `GetExpenses_WithoutToken_ReturnsUnauthorized` | 401 (yetkisiz erişim) |
| `PostExpense_WithoutToken_ReturnsUnauthorized` | 401 |
| `CreateExpense_WithInvalidInput_ReturnsBadRequest` | 400 |
| `ExpenseCrud_FullFlow_Works` | create/list/get/update/delete tam akış |
| `UserCannotAccessAnotherUsersExpense` | **Kullanıcı izolasyonu**: B, A'nın kaydını listeleyemez/okuyamaz/güncelleyemez/silemez (404); A'nınki değişmeden kalır |

### Flutter — `flutter analyze` + `flutter test`

- **`flutter analyze`**: Eklenen/değiştirilen dosyalarda **0 sorun**. Kalan 3
  `info` uyarısı, dokunulmayan mevcut dosyalardandır
  (`firebase_expense_repository.dart`, `expense_controller.dart`,
  `expense_form_page.dart`).
- **`flutter test`**: **16/16 başarılı.**
  - `expense_dto_test.dart`: API ↔ entity eşleme (title/description, ISO tarih).
  - `api_auth_repository_test.dart`: login/register/logout/getCurrentUserId,
    token saklama, hatada token saklanmaması.
  - `api_expense_repository_test.dart`: CRUD istek yolları, `getExpenses` başarı
    ve **Hive önbelleğine düşme** senaryoları.

---

## 9. GitHub Bağlantıları

- **Backend (ASP.NET Core API):** https://github.com/OsmanSelimMerey/ExpenseTracker.Api
- **Flutter uygulaması:** https://github.com/OsmanSelimMerey/expense_tracker

---

## 10. Kalan Riskler

1. **Sızmış eski kimlik bilgisi:** Depoya daha önce commit'lenmiş Neon PostgreSQL
   parolası **döndürülmeli (rotate)**. `appsettings.json` artık boştur, ancak git
   geçmişinde eski değer bulunabilir.
2. **Register `name` türetimi:** Flutter sözleşmesi yalnızca `(email, password)`
   aldığı için `name`, e-postanın yerel kısmından üretilir. Gerçek ad gerekiyorsa
   kayıt akışı/sözleşme genişletilmelidir.
3. **HTTPS sertifikası (Flutter):** Android emülatöründe self-signed dev
   sertifikası ek yapılandırma gerektirebilir; `ApiConstants.baseUrl` hedefe göre
   ayarlanmalıdır (`10.0.2.2`, cihaz IP'si vb.).
4. **Firebase bağımlılıkları:** `firebase_*` paketleri ve `firebase_options.dart`
   hâlâ mevcut (derlemenin bozulmaması için). Tamamen kaldırılması ayrı bir
   temizleme adımıdır.
5. **Windows Developer Mode:** Flutter'ın eklenti (plugin) derlemesi için
   sembolik bağlantı desteği gerekir (`start ms-settings:developers`). Bu, kodla
   ilgili değildir; `flutter test`/`analyze` etkilenmez.
6. **Test veritabanı:** Entegrasyon testleri InMemory sağlayıcı kullanır; gerçek
   PostgreSQL'e özgü davranışlar (ör. eşzamanlılık, kısıt ihlalleri) bu testlerde
   birebir kapsanmaz.
7. **Token süresi:** JWT 1 gün geçerlidir; yenileme (refresh token) akışı yoktur.
   Süre dolunca istemci yeniden giriş yapmalıdır.
