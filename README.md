# ExpenseTracker API

Bu proje, harcama ve gelir takibi yapan bir uygulamanın **arka yüzüdür** (API).

Telefon / web uygulaması (Flutter) buraya bağlanır; kullanıcılar kayıt olur, giriş yapar, harcama ekler ve bütçe tanımlar.

---

## Bu API ne işe yarar?

- Kullanıcı kaydı ve girişi
- Harcama ve gelir ekleme, düzenleme, silme
- Aylık bütçe koyma (örnek: “Bu ay yemeğe en fazla 3000 TL”)
- Şifremi unuttum / yeni şifre belirleme
- Her kullanıcının sadece kendi verisini görmesi

---

## Nasıl çalışır? (basitçe)

```text
  Flutter uygulaması  →  bu API  →  veritabanı (PostgreSQL)
```

1. Kullanıcı uygulamadan giriş yapar  
2. API bir **anahtar (token)** verir  
3. Sonraki isteklerde bu anahtar ile “benim hesabım” doğrulanır  
4. Veriler veritabanında saklanır  

---

## Bilgisayarda çalıştırmak

### Seçenek A — Kalıcı veri (önerilen)

PostgreSQL veritabanı Docker ile ayağa kalkar. Veriler uygulama kapanınca silinmez.

```powershell
docker compose up -d
cd ExpenseTracker.Api
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "buraya-en-az-64-karakterlik-uzun-bir-gizli-anahtar-yazin-1234567890"
dotnet run
```

### Seçenek B — Hızlı deneme (geçici)

Veritabanı kurmana gerek yok. Ama uygulamayı her kapattığında veriler silinir.

```powershell
$env:Database__Provider = "InMemory"
dotnet run --project ExpenseTracker.Api
```

---

## Çalıştığını nasıl anlarım?

Tarayıcıda şunları aç:

| Ne | Adres |
|----|--------|
| API test ekranı (Swagger) | `http://localhost:5123/swagger` |
| Sağlık kontrolü | `http://localhost:5123/health` → `Healthy` yazmalı |

Swagger’da önce **register** veya **login** yap, gelen token’ı **Authorize** kısmına yapıştır. Sonra diğer işlemleri deneyebilirsin.

---

## Ne tür istekler var?

### Giriş / hesap
- Kayıt ol  
- Giriş yap  
- Şifremi unuttum  
- Yeni şifre belirle  
- Profilimi gör / güncelle / sil  

### Harcamalar
- Listele  
- Ekle (gider veya gelir)  
- Düzenle  
- Sil  

### Bütçe
- Bu ay için limit koy (genel veya kategori: Yemek, Ulaşım…)  
- Ne kadar harcandığını ve limit aşıldı mı gör  

> Teknik adresler Swagger’da listelenir (`/api/auth/...`, `/api/expenses`, `/api/budgets`).

---

## Önemli notlar

- **Gizli bilgiler** (şifre anahtarı, veritabanı parolası) GitHub’a yazılmaz; User Secrets kullanılır.  
- **InMemory** sadece deneme içindir; gerçek kullanımda PostgreSQL tercih edilir.  
- Flutter istemci projesi: [expense_tracker](https://github.com/osmanmerey/expense_tracker)

---

## Testleri çalıştırmak

```powershell
dotnet test
```

Hepsi yeşil (geçti) olmalı.

---

## Daha fazla teknik detay

- Sürüm notları: [`CHANGELOG.md`](./CHANGELOG.md)  
- Postman koleksiyonu: `postman/ExpenseTracker.postman_collection.json`  
- Hata formatı: Problem Details (standart JSON hata cevabı)  
- Giriş denemeleri: rate limit (çok fazla yanlış denemeyi yavaşlatır)
