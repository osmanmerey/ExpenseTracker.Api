namespace ExpenseTracker.Api.Common;

/// <summary>Named rate-limiting policies registered in <c>Program.cs</c>.</summary>
public static class RateLimitPolicies
{
    /// <summary>Applied to authentication endpoints (register/login) to slow down brute-force attempts.</summary>
    public const string Auth = "auth";

    /// <summary>
    /// Fallback partition key used when the client's IP address cannot be resolved
    /// (e.g. <see cref="Microsoft.AspNetCore.Http.ConnectionInfo.RemoteIpAddress"/> is null),
    /// so all such requests share a single (still rate-limited) bucket instead of bypassing the limiter.
    /// </summary>
    public const string UnknownClientPartitionKey = "unknown";
}
