using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ExpenseTracker.Api.Repositories;

public class ExpenseRepository : IExpenseRepository
{
    private readonly AppDbContext _context;

    public ExpenseRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<Expense>> GetAllForUserNoTrackingAsync(Guid userId, CancellationToken cancellationToken = default) =>
        _context.Expenses
            .AsNoTracking()
            .Where(e => e.UserId == userId)
            .OrderByDescending(e => e.Date)
            .ToListAsync(cancellationToken);

    public Task<Expense?> GetByIdNoTrackingAsync(Guid id, Guid userId, CancellationToken cancellationToken = default) =>
        _context.Expenses
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId, cancellationToken);

    public Task<Expense?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default) =>
        _context.Expenses.FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId, cancellationToken);

    public async Task AddAsync(Expense expense, CancellationToken cancellationToken = default) =>
        await _context.Expenses.AddAsync(expense, cancellationToken);

    public void Remove(Expense expense) => _context.Expenses.Remove(expense);

    public Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);
}
