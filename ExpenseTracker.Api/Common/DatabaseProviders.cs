namespace ExpenseTracker.Api.Common;

/// <summary>
/// Supported values for <see cref="ConfigurationKeys.DatabaseProvider"/>.
/// </summary>
public static class DatabaseProviders
{
    public const string Postgres = "Postgres";
    public const string InMemory = "InMemory";

    /// <summary>Fixed database name used for the EF Core InMemory provider.</summary>
    public const string InMemoryDatabaseName = "ExpenseTrackerInMemory";
}
