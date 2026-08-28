namespace ExpenseTracker.Api.Common;

/// <summary>
/// Local-dev bootstrap only. Production must set <c>Auth:BootstrapAdminEmails</c>
/// explicitly (empty by default).
/// </summary>
public static class AuthBootstrapDefaults
{
    public const string DevelopmentAdminEmail = "boss@test.com";
}
