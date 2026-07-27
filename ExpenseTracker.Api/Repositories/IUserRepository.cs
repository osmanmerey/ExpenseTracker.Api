using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.Repositories;

/// <summary>
/// Data-access abstraction for <see cref="User"/> entities. Contains no business
/// rules - only persistence concerns (querying, adding, removing, saving).
/// </summary>
public interface IUserRepository
{
    /// <summary>Tracked read, suitable for update/delete operations.</summary>
    Task<User?> GetByIdAsync(Guid id);

    /// <summary>Untracked read, suitable for read-only responses.</summary>
    Task<User?> GetByIdNoTrackingAsync(Guid id);

    Task<User?> GetByEmailAsync(string normalizedEmail);

    Task<bool> EmailExistsAsync(string normalizedEmail, Guid? excludingUserId = null);

    Task AddAsync(User user);

    void Remove(User user);

    Task SaveChangesAsync();
}
