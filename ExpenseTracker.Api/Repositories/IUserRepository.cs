using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.Repositories;

/// <summary>
/// Data-access abstraction for <see cref="User"/> entities. Contains no business
/// rules - only persistence concerns (querying, adding, removing, saving).
/// </summary>
public interface IUserRepository
{
    /// <summary>Tracked read, suitable for update/delete operations.</summary>
    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>Untracked read, suitable for read-only responses.</summary>
    Task<User?> GetByIdNoTrackingAsync(Guid id, CancellationToken cancellationToken = default);

    Task<User?> GetByEmailAsync(string normalizedEmail, CancellationToken cancellationToken = default);

    Task<bool> EmailExistsAsync(string normalizedEmail, Guid? excludingUserId = null, CancellationToken cancellationToken = default);

    Task AddAsync(User user, CancellationToken cancellationToken = default);

    void Remove(User user);

    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
