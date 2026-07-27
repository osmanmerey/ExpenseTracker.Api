using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Services.Results;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Business logic for the authenticated user's own profile. Talks to
/// persistence only through <see cref="Repositories.IUserRepository"/>.
/// </summary>
public interface IUserService
{
    Task<UserResponseDto?> GetCurrentUserAsync(Guid userId);

    Task<UserUpdateOutcome> UpdateCurrentUserAsync(Guid userId, UserUpdateDto request);

    Task<bool> DeleteCurrentUserAsync(Guid userId);
}
