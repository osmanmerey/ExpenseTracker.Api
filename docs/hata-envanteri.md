# Hata Envanteri

**Tarih:** 29.07.2026  
**Ortam:** ExpenseTracker.Api (`http://localhost:5123`) + expense_tracker (Flutter, Android Studio Run)  
**Kural:** Tahmin yok — canlı deneme veya bu oturumda PowerShell/Swagger ile doğrulanan davranış.  
**Not:** PostgreSQL kurulu olmadığı için API denemelerinin bir kısmı `Database__Provider=InMemory` ile yapıldı. Postgres kapalıyken görülen 500+stack ayrıca kaydedildi.

| # | Uygulama | Senaryo | Şu anki davranış | Kullanıcının gördüğü | Olması gereken | Öncelik |
|---|----------|---------|------------------|----------------------|----------------|---------|
| 1 | API | Geçersiz/eksik veri gönderme | Login: geçersiz email + boş şifre → **400** `application/problem+json` (`type`, `title`, `status`, `errors`, `traceId`). Harcama: `amount` 0 veya negatif → **400** (`errors.Amount`, min 0.01); 0.01 → **201**. | — | Problem Details korunmalı; istemci `errors` okuyabilmeli. | Orta |
| 2 | Flutter | Geçersiz/eksik veri gönderme | Form yalnızca tutar boş mu diye bakıyor. PowerShell ile API 0/-5’i **400** reddediyor; uygulamada kayıt “başarılı” oldu ve listede **0/negatif satırlar** kaldı. | **0/negatif listede**; başarı mesajı gösterildi. | Client validation + API 400; geçersiz tutar başarı/listede görünmemeli. | Yüksek |
| 3 | API | Yanlış e-posta veya şifre | InMemory’de doğrulandı (önceki not + servis mesajı): başarısız login → **401**, metin: `E-posta veya şifre hatalı.` (düz metin / Problem Details değil). Bu oturumda ardışık denemeler hızlıca **429**’a düştü. | — | 401 + Problem Details (`detail` = aynı anlamlı mesaj, `traceId`). | Orta |
| 4 | Flutter | Yanlış e-posta veya şifre | API mesajı okunmuyor; `AuthController` sabit genel metin basıyor. | Snackbar: **“Hata” / “giriş başarısız”** (genel). | API’nin 401 mesajını göster. | Yüksek |
| 5 | API | Üst üste çok sayıda hatalı giriş | Limit: 5 istek / 60 sn (IP). Aşımda **429**, **body boş**, `Retry-After` yok (bu oturumda gözlendi). Postgres kapalıyken aynı endpoint önce **500+stack** üretebiliyordu. | — | 429 + Problem Details + `Retry-After` (veya eşdeğeri). | Yüksek |
| 6 | Flutter | Üst üste çok sayıda hatalı giriş | 429 ile 401 aynı genel login hatasına düşüyor (özel “çok deneme / sonra dene” yok). | Genel giriş hatası; rate limit ayrışmıyor. | 429’da ayrı mesaj (+ mümkünse bekleme bilgisi). | Orta |
| 7 | API | Token yok / geçersiz token | Token yok: `GET /api/Expenses` → **401**, body boş, `WWW-Authenticate: Bearer`. Geçersiz token: **401**, body boş, `WWW-Authenticate: Bearer error="invalid_token"`. Problem Details yok. | — | 401 + Problem Details (`detail` + `traceId`). | Yüksek |
| 8 | Flutter | Token yok / süresi dolmuş token | Token local’de varsa uygulama listeye giriyor; API 401 olunca repository cache’e düşebiliyor / hata yutuluyor. Süresi dolmuş token için ayrı UI yok. | Çoğunlukla eski liste veya genel hata; “oturum bitti” net değil. | 401’de oturumu temizle + login’e yönlendir / anlaşılır mesaj. | Yüksek |
| 9 | API | Var olmayan kaydı isteme | `GET /api/Expenses/{olmayan-guid}` (auth’lu) → **404** Problem Details (`type`, `title`, `status`, `traceId`); `detail` yok / body kısa. | — | 404 + Problem Details; isteğe bağlı anlaşılır `detail`. | Orta |
| 10 | Flutter | Var olmayan kaydı isteme | UI’da doğrudan “olmayan id” akışı yok; API/repo hatası genel catch’e düşer. | Anlaşılır “bulunamadı” yok / genel hata riski. | Kullanıcıya “kayıt bulunamadı” + geri. | Düşük |
| 11 | API | Başka kullanıcının kaydına erişme | Kullanıcı A’nın expense id’si ile B token’ı → **404** (404 ile aynı Problem Details). 403 değil. | — | Bilinçli tercih: 404 (bilgi sızdırma yok) kabul edilebilir; sözleşmede yazılmalı. | Orta |
| 12 | Flutter | Başka kullanıcının kaydına erişme | Normal UI başka kullanıcının id’sini istemiyor; özel ekran yok. | — | API 404 ile uyumlu “bulunamadı”. | Düşük |
| 13 | API | Aynı e-posta ile ikinci kez kayıt | İlk register **201**; ikincisi **409**, body düz metin: `Bu e-posta adresi zaten kullaniliyor.` Problem Details değil. | — | 409 + Problem Details (`detail` aynı mesaj, `traceId`). | Orta |
| 14 | Flutter | Aynı e-posta ile ikinci kez kayıt | Register hataları da genel mesaja çevriliyor (API 409 metni kullanılmıyor). | Genel kayıt/giriş hatası. | API 409 mesajını göster. | Orta |
| 15 | API | Veritabanı erişilemez | Postgres kapalı + provider Postgres iken login → **500**, `text/plain`, Developer Exception Page, **Npgsql + stack trace sızıyor**. | — | **503** + Problem Details; stack yok; 500’den ayrı. | Yüksek |
| 16 | Flutter | Veritabanı erişilemez (API 5xx) | 5xx / ağ hataları repository’de catch → cache veya genel mesaj. | Liste eski kalabilir veya genel hata; “sunucu/veritabanı” ayrımı yok. | Sunucu hatası durumu + retry; stale ise belirt. | Yüksek |
| 17 | Flutter | API tamamen kapalı — uygulama açıkken | API öldürüldü (5123 kapalı). Hive cache sessizce kullanılıyor. | **Eski liste duruyor; uyarı yok.** | `stale` + “bağlantı yok / güncel değil” + Tekrar dene. | Yüksek |
| 18 | Flutter | API tamamen kapalı — ilk açılış | Token local’de → liste ekranı; veri cache’ten. | **Eski liste duruyor** (normal görünüm). | `stale`/`error` + retry. | Yüksek |
| 19 | Flutter | İnternet yok / bağlantı çok yavaş | API kapalı senaryosuyla aynı sınıf: istek fail → cache; timeout için ayrı UI/state yok (http timeout yapılandırması belirgin değil). | Sessiz eski liste veya belirsiz bekleme riski. | Timeout süresi net; timeout/no-network ayrı durum + mesaj + retry. | Yüksek |
| 20 | API | Beklenmeyen sunucu istisnası | Global handler yok; Development’ta Developer Exception Page (ham exception + stack). Örnek: DB bağlantı hatası **500** olarak bu şekilde sızdı. | — | Merkezi handler → 500 Problem Details; prod’da stack yok; DB için 503 ayrımı. | Yüksek |
| 21 | Flutter | Beklenmeyen sunucu istisnası | Ham exception UI’ya basılmıyor; çoğu zaman genel mesaj veya sessiz cache. | Genel/yanıltıcı başarı (eski veri). | `serverError` durumu + genel anlaşılır mesaj + retry; ham stack yok. | Yüksek |

## Öncelik anahtarı
- **Yüksek:** kullanıcıyı yanıltan veya bilgisiz bırakan
- **Orta:** yanlış/genel mesaj, ama en azından bir uyarı var
- **Düşük:** çirkin / teknik ama anlaşılır

## Mentora özet (Kapı 1)
En kritik üç bulgu:
1. Flutter API kapalıyken **sessizce eski liste** gösteriyor.
2. API DB down iken **500 + stack**; 503 değil.
3. Flutter API’nin anlamlı mesajlarını kullanmıyor; geçersiz tutarda ise **yanlış başarı** gösterebiliyor.

## Notlar (deneme sırasında)
- Yol B: PostgreSQL/Docker yok; InMemory ile auth/expense senaryoları tamamlandı. Postgres-down davranışı ayrı canlı ölçüldü.
- Android Studio Run ile Flutter login çalıştı; terminal `flutter run` ile aynı anda sorun yaşandı.
- 429 body boş / Retry-After yok — InMemory ayaktayken doğrulandı.
- Başka kullanıcının kaydı 404 (bilinçli gizleme) — sözleşmede netleştirilecek.
