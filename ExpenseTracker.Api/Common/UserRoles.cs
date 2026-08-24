namespace ExpenseTracker.Api.Common;

/// <summary>
/// Canonical role names stored on <see cref="Models.User.Role"/> and issued as JWT role claims.
/// Values are lowercase so <c>[Authorize(Roles = ...)]</c> matches case-sensitively.
/// </summary>
public static class UserRoles
{
    public const string User = "user";
    public const string Admin = "admin";

    public const int MaxLength = 16;

    public static readonly string[] All = [User, Admin];

    public static string Normalize(string? role)
    {
        var normalized = role?.Trim().ToLowerInvariant();
        return string.IsNullOrEmpty(normalized) ? User : normalized;
    }

    public static bool IsValid(string? role)
    {
        var normalized = Normalize(role);
        return normalized is User or Admin;
    }

    public static bool IsAdmin(string? role) => Normalize(role) == Admin;
}
