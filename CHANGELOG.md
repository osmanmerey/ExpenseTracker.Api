# Changelog

Bu dosya, projedeki önemli değişiklikleri sürüm bazında listeler.

Format [Keep a Changelog](https://keepachangelog.com/tr/1.1.0/) temel alınarak
hazırlanmıştır ve proje [Semantic Versioning](https://semver.org/lang/tr/)
(MAJOR.MINOR.PATCH) kurallarına uyar.

## [Unreleased]

Henüz yayımlanmamış, üzerinde çalışılan değişiklikler buraya eklenir.

## [1.0.0] - 2026-07-27

İlk stabil sürüm. Kimlik doğrulamalı, katmanlı mimariye sahip bir harcama
takip REST API'si.

### Added
- Kullanıcı kayıt/giriş akışı, BCrypt ile parola hashleme ve JWT Bearer kimlik doğrulama.
- Kullanıcıya özel, yetkilendirilmiş harcama (expense) CRUD uç noktaları.
- Kullanıcı profili görüntüleme/güncelleme/silme uç noktaları (`/api/users/me`).
- DTO tabanlı istek/yanıt modelleri ve girdi doğrulama (DataAnnotations).
- EF Core ile çift veritabanı sağlayıcısı desteği: **PostgreSQL** (varsayılan)
  ve **InMemory** (isteğe bağlı, `Database:Provider` ortam değişkeni ile).
- Flutter Web istemcileri için yapılandırılabilir CORS politikası.
- Swagger/Swashbuckle üzerinden JWT destekli, keşfedilebilir API dokümantasyonu.
- xUnit + `WebApplicationFactory` ile uçtan uca entegrasyon test paketi (10 test).
- Postman koleksiyonu (`postman/ExpenseTracker.postman_collection.json`).

### Changed
- Mimari, **Controller → Service → Repository** katmanlarına ayrıldı:
  controller'lar artık `AppDbContext`'e doğrudan erişmiyor, sadece HTTP/durum
  kodu çeviriyor; iş kuralları `Services/`'e, veri erişimi `Repositories/`'e taşındı.
- Kod genelindeki magic number/string'ler (JWT anahtar uzunluğu, token ömrü,
  yapılandırma anahtarları, hata mesajları, doğrulama sınırları) `Common/`
  altında adlandırılmış sabitlere taşındı.

[Unreleased]: https://github.com/OsmanSelimMerey/ExpenseTracker.Api/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OsmanSelimMerey/ExpenseTracker.Api/releases/tag/v1.0.0
