# Hata Yanıtı Sözleşmesi

**Durum:** Kapı 2 — mentor onayı bekleniyor  
**Tarih:** 29.07.2026  
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

### 5) Hangi senaryo hangi durum kodu?

| Senaryo sınıfı | Kod | Örnek |
|----------------|-----|--------|
| **İstemci yanlış yaptı** | **4xx** | 400 validation; 401 yanlış şifre / token; 404 yok veya yetkisiz kaynak (bilinçli 404); 409 e-posta çakışması; 429 çok deneme |
| **Sunucu şu an hizmet veremiyor** | **503** | Veritabanına ulaşılamıyor, bağımlılık down |
| **Sunucuda beklenmeyen bir şey oldu** | **500** | Bug, yakalanmayan istisna (DB down değil) |

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

## API uygulama sınırları (onay sonrası kod)

1. Beklenen iş sonuçları → mevcut `Services/Results/` (istisna değil); controller Problem Details’e map eder.  
2. Beklenmeyen istisnalar → ASP.NET Core 8 `IExceptionHandler` + `AddProblemDetails` + `UseExceptionHandler` (controller’lara try-catch serpilmez).  
3. Validation, 401 (JWT), 429 (rate limit) boş/ayrı formatta kalmaz → aynı şema.  
4. Health: ayrı `GET /health` (veya `/health/ready`); iş ucuna 500 atarak öğrenilmez.  
5. Log seviyeleri: beklenen 4xx → Information/Warning; 429 → Warning; 503/500 → Error. Sessiz yutma yok.

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

- [ ] Standart: Problem Details (RFC 7807 / 9457) seçildi ve gerekçeli  
- [ ] Zorunlu alanlar + log anahtarı = `traceId`  
- [ ] Validation → `errors` map  
- [ ] Stack/exception yanıtta yok (Dev dahil); teknik detay log’da  
- [ ] 4xx / 503 / 500 ayrımı net  
- [ ] Mentor notu: user-friendly UI, teknik detay log, güvenlik  

**Onaydan sonra** kod (önce API, sonra Flutter) + testler + `REPORT.md` önce/sonra + iki PR.
