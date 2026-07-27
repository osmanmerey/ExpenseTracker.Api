namespace ExpenseTracker.Api.Services.Results;

/// <summary>Outcome of <see cref="IUserService.UpdateCurrentUserAsync"/>.</summary>
public enum UserUpdateOutcome
{
    Success,
    NotFound,
    EmailAlreadyExists
}
