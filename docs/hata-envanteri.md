# Hata Envanteri

**Tarih:** 29.07.2026  
**Ortam:** ExpenseTracker.Api (`http://localhost:5123`) + expense_tracker (Flutter, Android Studio Run)  
**Kural:** Tahmin yok — canlı deneme veya bu oturumda PowerShell/Swagger ile doğrulanan davranış.  
**Not:** PostgreSQL kurulu olmadığı için API denemelerinin bir kısmı `Database__Provider=InMemory` ile yapıldı. Postgres kapalıyken görülen 500+stack ayrıca kaydedildi.

---

## Mentor yönü (Kapı 1 onayı — tüm satırlara uygulanır)

Bu envanterdeki **“Olması gereken”** kolonunu şu ilkeye göre oku:

1. **Kullanıcılar teknik detay görmemeli** (exception metni, stack trace, SQL, iç yol, Npgsql vb.).
2. **Teknik detaylar loglanmalı** — geliştiriciler `traceId` / log ile takip edip çözebilsin.
3. **Kullanıcı user-friendly, hatayı açıklayan mesajlar görmeli** — ne olduğu anlaşılsın, ne yapacağı belli olsun.
4. **Neden:** Teknik detay kullanıcıya bir şey anlatmaz; aynı zamanda sistem hakkında bilgi verir → **güvenlik açığıdır**.

| Katman | Ne gider |
|--------|----------|
| Kullanıcı ekranı / API `detail` | Anlaşılır, güvenli mesaj |
| Log (API + uygulama) | Exception, stack, endpoint, status, `traceId` |

---

| # | Uygulama | Senaryo | Şu anki davranış | Kullanıcının gördüğü | Olması gereken | Öncelik |
|---|----------|---------|------------------|----------------------|----------------|---------|
| 1 | API | Geçersiz/eksik veri gönderme | Login: geçersiz email + boş şifre → **400** Problem Details (`errors`, `traceId`). Harcama: 0/negatif → **400** (`errors.Amount`); 0.01 → **201**. | — | User-friendly alan mesajları (`errors`/`detail`); teknik detay yok. Aynı `traceId` log’da. | Orta |
| 2 | Flutter | Geçersiz/eksik veri gönderme | Form yalnızca boş tutarı kesiyor. API 0/-5’i 400 reddediyor; uygulamada “başarılı” + listede 0/negatif göründü. | **0/negatif listede**; başarı mesajı. | User-friendly “geçersiz tutar” uyarısı; teknik/ham hata yok. Başarı yalnızca gerçek kayıt sonrası. Teknik neden log’da. | Yüksek |
| 3 | API | Yanlış e-posta veya şifre | **401**, metin: `E-posta veya şifre hatalı.` (düz metin; Problem Details değil). Ardışık denemede **429**. | — | User-friendly `detail` (aynı anlam); stack/exception yok; `traceId` + log. | Orta |
| 4 | Flutter | Yanlış e-posta veya şifre | API mesajı kullanılmıyor; genel metin. | **“Hata” / “giriş başarısız”** (belirsiz). | User-friendly: örn. “E-posta veya şifre hatalı.” Teknik detay UI’da yok; log’da status/`traceId`. | Yüksek |
| 5 | API | Üst üste çok hatalı giriş | **429**, body boş, `Retry-After` yok. DB down iken önce 500+stack görülebiliyordu. | — | User-friendly 429 mesajı (+ ne zaman dene); teknik detay yalnızca log. | Yüksek |
| 6 | Flutter | Üst üste çok hatalı giriş | 429 ile 401 aynı genel mesaja düşüyor. | Genel giriş hatası; rate limit anlaşılmıyor. | User-friendly: “Çok fazla deneme, sonra tekrar deneyin.” Teknik yok; log’da 429. | Orta |
| 7 | API | Token yok / geçersiz token | **401**, body boş; header’da `WWW-Authenticate`. | — | User-friendly `detail` + `traceId`; boş body ve teknik sızıntı yok. | Yüksek |
| 8 | Flutter | Token yok / süresi dolmuş token | Cache’e düşme / belirsiz hata; “oturum bitti” net değil. | Eski liste veya belirsiz hata. | User-friendly: “Oturumunuz sona erdi…” + login. Teknik yok; log’da 401/`traceId`. | Yüksek |
| 9 | API | Var olmayan kayıt | **404** Problem Details; `detail` zayıf/yok. | — | User-friendly `detail` (“Kayıt bulunamadı”); teknik yok; `traceId` log’da. | Orta |
| 10 | Flutter | Var olmayan kayıt | Genel catch; net mesaj yok. | Anlaşılır “bulunamadı” yok. | User-friendly “Kayıt bulunamadı” + geri. | Düşük |
| 11 | API | Başka kullanıcının kaydı | **404** (403 değil — varlık sızdırılmaz). | — | User-friendly 404 mesajı (bilinçli); teknik/“yetki detayı” sızdırma. Log’da takip. | Orta |
| 12 | Flutter | Başka kullanıcının kaydı | Normal UI’da yok. | — | User-friendly “bulunamadı”. | Düşük |
| 13 | API | Aynı e-posta ile 2. kayıt | **409**, düz metin mesaj. | — | User-friendly `detail` (aynı anlam) + `traceId`; teknik yok. | Orta |
| 14 | Flutter | Aynı e-posta ile 2. kayıt | API 409 metni kullanılmıyor. | Genel kayıt/giriş hatası. | User-friendly: “Bu e-posta zaten kullanılıyor.” Log’da 409. | Orta |
| 15 | API | Veritabanı erişilemez | **500** + Developer Exception Page; **Npgsql + stack sızıyor** (kullanıcı/istemci teknik detay görüyor). | — | **503** + user-friendly `detail` (“Servis geçici olarak kullanılamıyor…”). Stack/exception **yanıtta yok**; tam teknik detay **log’da** (`traceId`). Güvenlik: sistem bilgisi sızmasın. | Yüksek |
| 16 | Flutter | Veritabanı erişilemez (API 5xx) | Cache veya genel/ belirsiz davranış. | Eski liste veya belirsiz durum. | User-friendly sunucu/kesinti mesajı + retry; stale ise belirt. Ham 5xx/stack UI’da yok; log’da. | Yüksek |
| 17 | Flutter | API kapalı — açıkken | Hive cache sessiz. | **Eski liste; uyarı yok** (kullanıcı hatayı anlamıyor). | User-friendly: “Bağlantı yok / veriler güncel olmayabilir” + Tekrar dene. Teknik yok; log’da bağlantı hatası. | Yüksek |
| 18 | Flutter | API kapalı — ilk açılış | Cache + token ile liste. | **Eski liste; normal görünüm.** | Aynı user-friendly stale/error mesajı + retry. | Yüksek |
| 19 | Flutter | İnternet yok / yavaş | Timeout/ayrı UI belirsiz; cache riski. | Sessiz eski liste / belirsiz bekleme. | User-friendly bağlantı/zaman aşımı mesajı + retry. Teknik yok; log’da. | Yüksek |
| 20 | API | Beklenmeyen sunucu istisnası | Handler yok; istemciye exception + **stack** gidebiliyor. | — | **500** + user-friendly genel `detail`. Stack/exception **yanıtta yok** (güvenlik); **log’da Error** + `traceId`. DB down ile karışmaz (503). | Yüksek |
| 21 | Flutter | Beklenmeyen sunucu istisnası | Çoğunlukla genel mesaj veya sessiz cache. | Belirsiz / yanıltıcı (eski veri). | User-friendly “Bir sorun oluştu, tekrar deneyin” + retry. Ham exception UI’da yok; log’da. | Yüksek |

## Öncelik anahtarı
- **Yüksek:** kullanıcıyı yanıltan, bilgisiz bırakan veya teknik detay / güvenlik sızıntısı
- **Orta:** mesaj var ama yeterince user-friendly değil veya format eksik
- **Düşük:** nadir UI yolu; yine de user-friendly olmalı

## Mentora özet
1. Kullanıcıya giden teknik sızıntı var (ör. DB down → stack) → güvenlik + anlamsız UX.  
2. Flutter sessiz eski liste / yanlış başarı → kullanıcı hatayı anlamıyor.  
3. Anlamlı API mesajları UI’da kullanılmıyor → user-friendly değil.  
4. Hedef (mentor): **user-friendly mesaj kullanıcıya; teknik detay log’a.**

## Notlar (deneme sırasında)
- Yol B: PostgreSQL/Docker yok; InMemory ile auth/expense senaryoları tamamlandı. Postgres-down davranışı ayrı canlı ölçüldü.
- Android Studio Run ile Flutter login çalıştı; terminal `flutter run` ile aynı anda sorun yaşandı.
- 429 body boş / Retry-After yok — InMemory ayaktayken doğrulandı.
- Başka kullanıcının kaydı 404 (bilinçli gizleme) — sözleşmede netleştirilecek.
