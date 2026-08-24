using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.Repositories;

public interface IUserRepository
{
    Task<IEnumerable<User>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    Task<User?> GetByIdNoTrackingAsync(Guid id, CancellationToken cancellationToken = default);

    Task<User?> GetByEmailAsync(string normalizedEmail, CancellationToken cancellationToken = default);

    Task<bool> EmailExistsAsync(string normalizedEmail, Guid? excludingUserId = null, CancellationToken cancellationToken = default);

    Task AddAsync(User user, CancellationToken cancellationToken = default);

    void Remove(User user);

    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}