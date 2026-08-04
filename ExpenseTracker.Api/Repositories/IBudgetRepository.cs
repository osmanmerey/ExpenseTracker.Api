using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.Repositories;

public interface IBudgetRepository
{
    Task<List<Budget>> GetForUserPeriodNoTrackingAsync(
        Guid userId,
        int year,
        int month,
        CancellationToken cancellationToken = default);

    Task<Budget?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);

    Task<Budget?> GetByIdNoTrackingAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);

    Task<bool> ExistsForPeriodAsync(
        Guid userId,
        int year,
        int month,
        string category,
        Guid? excludeId = null,
        CancellationToken cancellationToken = default);

    Task AddAsync(Budget budget, CancellationToken cancellationToken = default);

    void Remove(Budget budget);

    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
