namespace ExpenseTracker.Api.Common;

/// <summary>Named rate-limiting policies registered in <c>Program.cs</c>.</summary>
public static class RateLimitPolicies
{
    /// <summary>Applied to authentication endpoints (register/login) to slow down brute-force attempts.</summary>
    public const string Auth = "auth";
}
