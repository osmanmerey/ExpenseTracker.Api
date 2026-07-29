namespace ExpenseTracker.Api.Common;

/// <summary>
/// User-facing and startup-failure error messages, centralized so the same
/// wording isn't duplicated (and risks drifting) across controllers/services.
/// </summary>
public static class ErrorMessages
{
    public const string EmailAlreadyExists = "Bu e-posta adresi zaten kullanılıyor.";
    public const string InvalidCredentials = "E-posta veya şifre hatalı.";
    public const string Unauthorized = "Oturum gerekli veya geçersiz. Lütfen tekrar giriş yapın.";
    public const string NotFound = "Kayıt bulunamadı.";
    public const string TooManyRequests = "Çok fazla deneme yaptınız. Lütfen bir süre sonra tekrar deneyin.";
    public const string ServiceUnavailable = "Servis geçici olarak kullanılamıyor. Lütfen sonra tekrar deneyin.";
    public const string UnexpectedError = "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.";

    public const string JwtKeyMissing =
        "Jwt:Key must be configured and contain at least 64 characters.";

    public const string JwtIssuerOrAudienceMissing =
        "Jwt:Issuer and Jwt:Audience must be configured.";

    public const string ConnectionStringMissing =
        "ConnectionStrings:DefaultConnection must be configured using user secrets or an environment variable.";
}
