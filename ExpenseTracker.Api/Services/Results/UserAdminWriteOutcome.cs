namespace ExpenseTracker.Api.Services.Results;

/// <summary>Outcome of admin user-role updates and admin-initiated deletes.</summary>
public enum UserAdminWriteOutcome
{
    Success,
    NotFound,
    InvalidRole,
    LastAdmin
}
