using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.Repositories;

/// <summary>
/// Data-access abstraction for <see cref="Expense"/> entities. Every method is
/// scoped by <c>userId</c> so cross-user access can never leak past this layer.
/// </summary>
public interface IExpenseRepository
{
    Task<List<Expense>> GetAllForUserNoTrackingAsync(Guid userId, CancellationToken cancellationToken = default);

    Task<Expense?> GetByIdNoTrackingAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);

    /// <summary>Tracked read, suitable for update/delete operations.</summary>
    Task<Expense?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);

    Task AddAsync(Expense expense, CancellationToken cancellationToken = default);

    void Remove(Expense expense);

    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
