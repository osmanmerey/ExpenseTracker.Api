using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Services.Results;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Business logic for the authenticated user's own profile. Talks to
/// persistence only through <see cref="Repositories.IUserRepository"/>.
/// </summary>
public interface IUserService
{
    Task<UserResponseDto?> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default);

    Task<UserUpdateOutcome> UpdateCurrentUserAsync(Guid userId, UserUpdateDto request, CancellationToken cancellationToken = default);

    Task<bool> DeleteCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default);

    // --- YENİ EKLENEN ADMIN METOTLARI ---
    Task<IEnumerable<UserResponseDto>> GetAllUsersAsync(CancellationToken cancellationToken = default);

    Task<bool> UpdateUserRoleAsync(Guid userId, string role, CancellationToken cancellationToken = default);

    Task<bool> DeleteUserAsync(Guid userId, CancellationToken cancellationToken = default);
}