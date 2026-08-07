namespace ExpenseTracker.Api.Common;

/// <summary>
/// Centralized configuration key names (appsettings.json / user secrets / env vars),
/// so the same literal string is never re-typed in multiple places.
/// </summary>
public static class ConfigurationKeys
{
    public const string JwtKey = "Jwt:Key";
    public const string JwtIssuer = "Jwt:Issuer";
    public const string JwtAudience = "Jwt:Audience";

    public const string DatabaseProvider = "Database:Provider";
    public const string DefaultConnectionName = "DefaultConnection";
    public const string DatabaseCommandTimeoutSeconds = "Database:CommandTimeoutSeconds";
    public const string ApplyMigrationsOnStartup = "Database:ApplyMigrationsOnStartup";

    public const string CorsAllowedOrigins = "Cors:AllowedOrigins";

    public const string AuthRateLimitPermitLimit = "RateLimiting:AuthPermitLimit";
    public const string AuthRateLimitWindowSeconds = "RateLimiting:AuthWindowSeconds";

    /// <summary>Dev-only: return reset token in forgot-password JSON. Must stay false in Production.</summary>
    public const string AuthExposeResetTokenInResponse = "Auth:ExposeResetTokenInResponse";
}
