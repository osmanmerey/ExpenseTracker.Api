namespace ExpenseTracker.Api.Common;

/// <summary>
/// Security-related constants (JWT signing/validation), kept in one place instead
/// of scattered magic numbers across Program.cs and the auth service.
/// </summary>
public static class SecurityConstants
{
    /// <summary>HmacSha512 (used to sign tokens) requires a key of at least 512 bits (64 bytes).</summary>
    public const int MinimumJwtKeyLengthInChars = 64;

    /// <summary>How long an issued JWT remains valid.</summary>
    public static readonly TimeSpan TokenLifetime = TimeSpan.FromDays(1);

    /// <summary>Allowed clock drift when validating a token's expiry.</summary>
    public static readonly TimeSpan ClockSkew = TimeSpan.FromMinutes(1);

    /// <summary>
    /// Default brute-force protection for /api/auth endpoints, used when
    /// <see cref="ConfigurationKeys.AuthRateLimitPermitLimit"/> is not configured.
    /// </summary>
    public const int DefaultAuthRateLimitPermitLimit = 5;

    public const int DefaultAuthRateLimitWindowSeconds = 60;
}
