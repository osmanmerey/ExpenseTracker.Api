# Adım 3–4 Araştırma / Uygulama Cevapları

**Tarih:** 29.07.2026  
**Bağlam:** `docs/hata-sozlesmesi.md` + mevcut kod  
**Not:** Flutter asıl çalışma kopyası: `C:\expenstracker` (Android Studio).

---

# Adım 3 — API

## 1) Yakalanmayan istisnalar: ASP.NET Core 8 önerilen yol?

**Önerilen yol:** `IExceptionHandler` + `AddExceptionHandler<T>()` + `AddProblemDetails()` + pipeline’da `app.UseExceptionHandler()`.

**Ne zaman devreye girer?** İstek middleware / endpoint / action içinde **yakalanmamış bir exception** fırladığında. Pipeline’ın exception handling aşamasında çalışır; her controller’a try-catch yazmayı gerektirmez.

Bu projedeki karşılık: `Errors/GlobalExceptionHandler.cs`, kayıt `Program.cs` içinde.

## 2) Controller’lar hataları nasıl ele alıyor? Merkezi çözüm try-catch ister mi?

**Beklenen iş hataları:** Servis `Services/Results/` (veya null / bool) döner → controller HTTP’ye map eder (`ProblemResult` / 201 / 204). Örnek: yanlış şifre → `LoginResult` başarısız → 401 Problem Details.

**Beklenmeyen istisnalar:** Controller try-catch yok → `GlobalExceptionHandler`.

**Sonuç:** Merkezi çözüm controller’lara try-catch dağıtmayı gerektirmez.

## 3) DB erişilemez vs kod bug’ı — fark ve kodlar?

| Durum | Anlam | HTTP |
|--------|--------|------|
| DB / bağımlılık yok, transient bağlantı hatası | Sunucu şu an hizmet veremiyor | **503** |
| NullReference, mantık hatası, öngörülmeyen exception | Sunucuda beklenmeyen bug | **500** |

Handler `Npgsql*`, `SocketException`, “transient failure” içeren zinciri **503**; diğerlerini **500** yapar. İkisi aynı kod olmamalı — sözleşme ve kod bunu ayırır.

## 4) Doğrulama hataları aynı içerik yapısında mı?

Evet. `[ApiController]` + `AddProblemDetails` → `application/problem+json` (`type`, `title`, `status`, `errors`, `traceId`).  
Test: `ValidationError_ReturnsProblemDetailsWithErrorsAndTraceId`.

## 5) 429 yanıtında ne var? Retry bilgisi var mı?

Önceden: çoğu zaman **boş body**.  
Şimdi: Problem Details (`detail`, `traceId`, `retryAfterSeconds`) + header **`Retry-After`** (pencere saniyesi).  
Test: `AuthRateLimit_Returns429ProblemDetailsWithRetryAfter`.

## 6) Results vs exception ayrımı

- Beklenen iş sonucu → **istisna değil**, `Services/Results/` / null / bool → controller map.  
- Merkezi handler → **yalnızca yakalanmayan / beklenmeyen** istisnalar.  
İkisi karıştırılmadı.

## 7) Loglama cevapları

### Hangi hata hangi seviyede? 4xx ile 5xx aynı mı?

| Tür | Seviye | Neden |
|-----|--------|--------|
| Beklenen 4xx (validation, yanlış şifre, 404, 409) | Information / Warning veya hiç Error değil | Normal istemci davranışı; Error gürültüsü yaratır |
| 429 | Warning | Kötüye kullanım / brute-force sinyali |
| 503 / 500 / yakalanmayan istisna | **Error** (+ exception) | Operasyonel veya bug; incelenmeli |

**Hayır, aynı seviyede loglanmaz.** İstemci yanlışlığı ile sunucu çökmesi aynı değildir.

### Kullanıcı “şu saatte hata aldım” → log’da ortak ne?

**`traceId`:** hem Problem Details yanıtında hem `LogError(..., TraceId={TraceId}, ...)` satırında.

### Log’da bulunmaması gerekenler

Parola, token, hash, `Authorization` header değeri, connection string secret’ı, mümkünse tam PII.

Kod gözü: `ApiClient` / handler token’ı loglamaz; Flutter `logAppException` da token yazmaz.

### Yakalanıp sessizce geçilirse ne olur?

Hata kaybolur; kullanıcı veya geliştirici takip edemez; bazen yanlış “başarı” görünür.  
Eski Flutter `getExpenses` catch’i buna yakındı (cache’e düşüp UI’ya haber vermemek). Şimdi `stale` + log var. API’de beklenmeyenler handler’da loglanır.

### “Kayıt bulunamadı” her istekte Error mı?

**Hayır.** Beklenen 404 iş sonucu; Error değil. Aksi halde gerçek 5xx gürültüde kaybolur.

## 8) Health — iş ucuna 500 atmadan

`GET /health` (+ EF `AddDbContextCheck`). Ayakta olma durumu ayrı uçtan öğrenilir.

## 9) DB süre sınırı ve iptal

- Npgsql **`CommandTimeout(30)`** ayarlandı.  
- Controller’da `CancellationToken` parametresi var.  
- **Kısmi boşluk:** token henüz servis/repo/EF çağrılarına sistematik iletilmiyor (sonraki iyileştirme).

## 10) Testler ve “DB’yi bozmadan nasıl test?”

- `ProblemDetailsAssertions` ile body sözleşmesi.  
- 500: `GET /api/diagnostic/boom` (yalnız Testing).  
- 503: `GET /api/diagnostic/db-down` (SocketException + transient mesajı; gerçek Postgres kapatılmaz).  
- 429: düşük limit’li test factory.  

Altyapı: `WebApplicationFactory` + InMemory DB; diagnostic uçlar Testing ortamında.

---

# Adım 4 — Flutter

## 1) Yanıt bekleme süresi? Sunucu yanıtlamazsa ne olur?

`ApiConstants.requestTimeout = 15 saniye`.  
`ApiClient` istekleri `.timeout(...)` ile sarar. Süre aşımında `AppErrorKind.timeout` → kullanıcıya zaman aşımı mesajı; teknik detay log’da.

## 2) API hata yanıtı okunuyor mu? Eski bulgu nerede oluşuyordu?

**Eski:** `AuthController.login` catch’te sabit  
`"Giriş başarısız: Bilgilerinizi kontrol edin."` — body ignore.  

**Şimdi:** `ProblemDetails.tryParse` + `appExceptionFromResponse` → `AppException.userMessage` (4xx’te API `detail`).  
Auth/expense repository’ler bunu fırlatır; controller gösterir.

## 3) Hata türleri

`AppErrorKind`:  
`validation`, `unauthorized`, `notFound`, `conflict`, `tooManyRequests`, `serverUnavailable`, `serverError`, `noConnection`, `timeout`, `unknown`.  

UI’da ham `Exception.toString()` yok.

## 4) Ne zaman API mesajı, ne zaman genel mesaj?

| Durum | Mesaj |
|--------|--------|
| 400 / 401 / 404 / 409 / 429 ve anlamlı `detail` (veya `errors`) | **API mesajı** |
| 500 / 503 / parse edilemeyen 5xx | Genel: “Sunucu şu an yanıt veremiyor…” |
| noConnection / timeout | Genel bağlantı / zaman aşımı metni |

Yanlış şifre (401 detail) ile sunucu 500 **aynı muameleyi görmez**.

## 5) Uygulama log’u

- **Nereye:** `debugPrint` / Logcat (`logAppException`).  
- **Ne yazılır:** kind, status, `traceId`, userMessage, context.  
- **Ne yazılmaz:** parola, token.  
- API `traceId` yanıtta varsa log’a alınır → API log’u ile eşleşir.

## 6) API kapalıyken eski liste — nereden, ne yaptık?

- **Kaynak:** Hive (`expensesCacheBox`, `cached_expenses_$userId`).  
- **Eski yol:** `getExpenses` catch → cache dön → controller `success` sanır → sessiz.  
- **Yeni:** `ExpenseLoadResult(isStale: true)` → `ViewState.stale` → banner (“güncel olmayabilir / bağlantı yok”) + **Tekrar Dene**.  
Çevrimdışı kaldırılmadı; kullanıcının bilmesi sağlandı.

## 7) Çıkış yolu

- `error`: mesaj + Tekrar Dene  
- `stale`: banner + Tekrar Dene  
- Form/auth: snackbar; kullanıcı geri gidebilir  

## 8) Flutter testler

- Stale (cache + API fail) → yalnız sessiz liste değil  
- Timeout / server error → `ViewState.error`  
- Problem Details parse + auth detail  

(`flutter test` yeşil; controller testleri `expense_controller_error_test.dart`)

---

# Adım 5

`REPORT.md` §11 önce/sonra tablosu eklendi.

---

# Bilinen küçük boşluklar

1. ~~API: `CancellationToken` controller → service → repo → EF iletimi~~ (yapıldı).
2. ~~API: 4xx → `ClientErrorLoggingMiddleware` ile `LogWarning` + `TraceId`~~ (yapıldı; 5xx hâlâ `LogError`).
3. İki Flutter kopyası: teslim/PR için `C:\expenstracker` esas alınmalı.
