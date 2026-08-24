using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ExpenseTracker.Api.Repositories;

public class BudgetRepository : IBudgetRepository
{
    private readonly AppDbContext _context;

    public BudgetRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<Budget>> GetForUserPeriodNoTrackingAsync(
        Guid userId,
        int year,
        int month,
        CancellationToken cancellationToken = default) =>
        _context.Budgets
            .AsNoTracking()
            .Where(b => b.UserId == userId && b.Year == year && b.Month == month)
            .OrderBy(b => b.Category)
            .ToListAsync(cancellationToken);

    public Task<Budget?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default) =>
        _context.Budgets.FirstOrDefaultAsync(b => b.Id == id && b.UserId == userId, cancellationToken);

    public Task<Budget?> GetByIdNoTrackingAsync(Guid id, Guid userId, CancellationToken cancellationToken = default) =>
        _context.Budgets
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id && b.UserId == userId, cancellationToken);

    public Task<bool> ExistsForPeriodAsync(
        Guid userId,
        int year,
        int month,
        string category,
        Guid? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        // Case-insensitive match (PostgreSQL default is case-sensitive on =).
        var key = category.ToLower();
        var query = _context.Budgets.AsNoTracking()
            .Where(b =>
                b.UserId == userId &&
                b.Year == year &&
                b.Month == month &&
                b.Category.ToLower() == key);

        if (excludeId.HasValue)
            query = query.Where(b => b.Id != excludeId.Value);

        return query.AnyAsync(cancellationToken);
    }

    public async Task AddAsync(Budget budget, CancellationToken cancellationToken = default) =>
        await _context.Budgets.AddAsync(budget, cancellationToken);

    public void Remove(Budget budget) => _context.Budgets.Remove(budget);

    public Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);
}
