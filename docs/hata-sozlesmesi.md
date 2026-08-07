# Hata Yanıtı Sözleşmesi

**Durum:** Uygulandı (tek kanonik dosya; `-yeni` kopyaları kaldırıldı)  
**Tarih:** 29.07.2026 (güncelleme: 2026-08)  
**Kapsam:** ExpenseTracker.Api + expense_tracker (Flutter). İki repo da bu dokümana bakar; sözleşme değişirse bu dosya da güncellenir.  
**Girdi:** `docs/hata-envanteri.md` + Kapı 1 mentor notu

---

## Mentor notu (Kapı 1) — tüm kararlara bağlanır

| Katman | Kural |
|--------|--------|
| Kullanıcı (ekran) | User-friendly, ne olduğunu anlatan mesaj. Teknik detay **yok**. |
| API yanıtı | Kullanıcıya gösterilebilir kısa metin (`detail` / `errors`). Exception, stack, SQL, iç yol **yok**. |
| Log (API + Flutter) | Teknik ayrıntı burada: exception, stack, endpoint, status, `traceId`. Geliştirici takip edip çözebilsin. |

**Neden:** Teknik detay kullanıcıya bir şey anlatmaz; sistem hakkında bilgi verir → **güvenlik açığı**.

---

## Araştırma soruları ve kararlar

### 1) Yaygın bir standart var mı? Neden onu seçtik?

**Evet: RFC 7807 Problem Details** (`Content-Type: application/problem+json`).  
Güncel adı pratikte RFC 9457 ile aynı modeldir.

**Neden seçildi (sıfırdan format uydurulmadı):**
- HTTP API’lerinde yaygın ve belgelenmiş.
- ASP.NET Core 8’de `AddProblemDetails` / validation hataları zaten bu modele yakın üretir.
- Flutter tek parse yoluna bağlanır; iki repo aynı şemaya bakar.

### 2) Her hatada bulunması gereken alanlar? Log’da isteği bulduran alan hangisi?

| Alan | Zorunlu? | Rolü |
|------|----------|------|
| `type` | Evet | Hata kategorisi (URI) |
| `title` | Evet | Kısa başlık |
| `status` | Evet | HTTP durum kodu ile aynı |
| `detail` | Evet* | Kullanıcıya güvenle gösterilebilir açıklama (TR). *Validation’da özet olabilir; asıl alan mesajları `errors`’ta. |
| `instance` | Evet | İstek yolu (`HttpContext.Request.Path`) — tüm Problem Details üreticileri (`ProblemFactory`) aynı alanı yazar. |
| `traceId` | Evet | **Log eşleştirme anahtarı.** Kullanıcı “şu saatte hata aldım” deyince yanıtındaki `traceId` ile log satırı bulunur. |

Koşullu: `errors` (yalnız 400 validation), `retryAfterSeconds` (yalnız 429; ayrıca `Retry-After` header).

### 3) Doğrulama hatalarında istemci hangi alanın neden reddedildiğini nasıl anlar?

`errors` nesnesi ile:

```json
"errors": {
  "Email": ["The Email field is not a valid e-mail address."],
  "Amount": ["The field Amount must be between 0.01 and ..."]
}
```

Anahtar = alan adı, değer = o alana ait mesaj listesi. Flutter bu map’i okuyup alan bazlı veya birleşik user-friendly metin üretir. Ham framework metni olduğu gibi dump edilmez; anlaşılır Türkçe’ye çevrilebilir / `detail` özeti kullanılabilir.

### 4) Teknik ayrıntı (exception, stack) yanıtta olmalı mı? Dev / Prod farkı?

| | Yanıt (client) | Log |
|--|----------------|-----|
| **Production** | Stack / exception **yok**. Genel `detail`. | Tam teknik detay + `traceId` |
| **Development** | Yine stack / exception **yok** (güvenlik + alışkanlık aynı kalsın). | Tam teknik detay + `traceId` (geliştirici burada bakar) |

**Karar:** Ortam farkı **yanıtta değil, log/debug tarafında**dır. Developer Exception Page istemciye stack sızdırmaz; merkezi handler her ortamda güvenli Problem Details döner.

### 4b) `traceId` ile teknik log’a nasıl erişilir? Stack nereye yazılır, nereden okunur?

Bu bölüm sözleşmenin **operasyon kuralıdır** (kod + günlük kullanım). Önceki sürümde yalnızca “log’da tutulur” denmişti; erişim yolu burada netleştirildi.

#### Stack trace nereye sağlanır?

| Hedef | Stack / exception yazılır mı? |
|-------|-------------------------------|
| HTTP yanıtı (Problem Details) | **Hayır** |
| Flutter UI (snackbar, dialog) | **Hayır** |
| **API log** (`ILogger`, merkezi `IExceptionHandler` içinde) | **Evet** — 503/500 ve yakalanmayan istisnalarda `LogError(exception, "... TraceId={TraceId}", traceId)` |
| **Flutter uygulama log’u** (debug console / logger) | **Evet** — en azından: endpoint, HTTP status, `traceId`, hata türü. Ham stack UI’ya değil log’a. |

`traceId` kaynağı (API): `HttpContext.TraceIdentifier` veya `Activity.Current?.Id`.  
Aynı değer hem yanıt gövdesindeki `traceId` alanına hem log satırına yazılır.

#### Geliştirici teknik detaya nasıl erişir? (adım adım)

1. Kullanıcı/istemci hatayı alır → yanıttaki (veya Flutter log’undaki) **`traceId`** not edilir.  
2. **API tarafı:** API’nin çalıştığı **terminal / konsol çıktısı**na bakılır (bu projede varsayılan ASP.NET Core console logging).  
3. Konsolda / log’da **`traceId` değeri aranır**.  
4. Eşleşen satırda **exception tipi, mesaj ve stack trace** görülür → bug oradan çözülür.

**Flutter tarafı:** Android Studio Logcat / Run konsolu. Oradaki `traceId` ile API log’u eşleştirilir.

```
[Yanıt veya Flutter log]  traceId = 00-abc...
              │
              ▼
[API terminal / log]     aynı traceId → exception + stack trace
```

#### Bu projede pratik konum (lokal)

| Ne | Nerede |
|----|--------|
| API log + stack | `dotnet run` yapılan terminal |
| Flutter log + `traceId` | Android Studio Run konsolu / Logcat |
| İleride (opsiyonel) | Dosya, Seq, Application Insights — arama anahtarı yine `traceId` |

**Özet kural:** Stack’i **log’a sağlarız**; erişim **log çıktısından `traceId` ile arayarak** yapılır. Kullanıcıya stack verilmez.

### 5) Hangi senaryo hangi durum kodu?

| Senaryo sınıfı | Kod | Örnek |
|----------------|-----|--------|
| **İstemci yanlış yaptı** | **4xx** | 400 validation; 401 yanlış şifre / token; 403 yetki yok; 404 yok veya yetkisiz kaynak (bilinçli 404); 409 e-posta/bütçe çakışması; 429 çok deneme |
| **Sunucu şu an hizmet veremiyor** | **503** | Veritabanına ulaşılamıyor, bağlantı/SqlState `08*`/`57P*`, geçici Npgsql |
| **Sunucuda beklenmeyen bir şey oldu** | **500** | Bug, unique/FK gibi veri hataları, yakalanmayan istisna (DB down değil) |

Özet ayrım:
- İstemci hatası → **4xx**
- Geçici / altyapı kesintisi → **503**
- Beklenmeyen sunucu hatası → **500**  
**503 ile 500 karıştırılmaz.**

---

## Örnek hata gövdesi

```json
{
  "type": "https://httpstatuses.com/401",
  "title": "Unauthorized",
  "status": 401,
  "detail": "E-posta veya şifre hatalı.",
  "instance": "/api/auth/login",
  "traceId": "00-abc123def456-00"
}
```

**400 validation** → yukarıdakiler + `errors`  
**429** → `detail` + `retryAfterSeconds` + header `Retry-After`  
**503** → `detail`: "Servis geçici olarak kullanılamıyor. Lütfen sonra tekrar deneyin."  
**500** → `detail`: "Beklenmeyen bir hata oluştu." (stack yok)

### Yanıtta asla

Exception tipi/mesajı, stack trace, SQL, dosya yolu, connection string, token, parola, hash.

---

## API yanıt sözleşmesi notları (başarı gövdesi)

- `TransactionKind` (`Expense` / `Income`) JSON’da **string** olarak serileşir (`JsonStringEnumConverter`). Sayısal enum bekleyen istemciler kırılır; Flutter tarafı string ile hizalı olmalıdır.

---

## API uygulama sınırları (onay sonrası kod)

1. Beklenen iş sonuçları → mevcut `Services/Results/` (istisna değil); controller Problem Details’e map eder.  
2. Beklenmeyen istisnalar → ASP.NET Core 8 `IExceptionHandler` + `AddProblemDetails` + `UseExceptionHandler` (controller’lara try-catch serpilmez).  
3. Validation, 401 (JWT), 403, 429 (rate limit) boş/ayrı formatta kalmaz → aynı şema (`ProblemFactory`).  
4. Health: ayrı `GET /health` (veya `/health/ready`); iş ucuna 500 atarak öğrenilmez.  
5. Log seviyeleri: beklenen 4xx → Information/Warning; 429 → Warning; 503/500 → Error. İstemci iptali (`OperationCanceledException` + `RequestAborted`) Error değil. Sessiz yutma yok.  
6. Handler içinde stack **yalnız** `ILogger` ile yazılır; yanıta konmaz (bkz. §4b).

---

## Flutter uygulama sınırları (onay sonrası kod)

**Hata türleri:** `validation`, `unauthorized`, `notFound`, `conflict`, `tooManyRequests`, `serverUnavailable`, `serverError`, `noConnection`, `timeout`, `unknown`

**Mesaj kuralı:**
- Anlaşılır 4xx `detail` / `errors` → kullanıcıya göster  
- 5xx / network / timeout → genel user-friendly mesaj; teknik detay uygulama log’unda (`traceId` dahil)  
- Ham `Exception.toString()` UI’da yok  

**UI durumları:** `loading` | `data` | `empty` | `error` | `stale`  
`stale` = eski cache + “güncel olmayabilir / bağlantı yok” + Tekrar dene (sessiz cache yasak).

---

## Kapı 2 — onay checklist

- [x] Standart: Problem Details (RFC 7807 / 9457) seçildi ve gerekçeli  
- [x] Zorunlu alanlar + log anahtarı = `traceId` (+ `instance`)  
- [x] Validation → `errors` map  
- [x] Stack/exception yanıtta yok (Dev dahil); teknik detay log’da  
- [x] **§4b:** stack nereye yazılır / `traceId` ile log’a nasıl erişilir yazılı  
- [x] 4xx / 503 / 500 ayrımı net  
- [x] Mentor notu: user-friendly UI, teknik detay log, güvenlik  
