using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Models;
using ExpenseTracker.Api.Repositories;

namespace ExpenseTracker.Api.Services;

public class ExpenseService : IExpenseService
{
    private readonly IExpenseRepository _expenseRepository;

    public ExpenseService(IExpenseRepository expenseRepository)
    {
        _expenseRepository = expenseRepository;
    }

    public async Task<IEnumerable<ExpenseResponseDto>> GetAllAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var expenses = await _expenseRepository.GetAllForUserNoTrackingAsync(userId, cancellationToken);
        return expenses.Select(ToResponse);
    }

    public async Task<ExpenseResponseDto?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default)
    {
        var expense = await _expenseRepository.GetByIdNoTrackingAsync(id, userId, cancellationToken);
        return expense is null ? null : ToResponse(expense);
    }

    public async Task<ExpenseResponseDto> CreateAsync(Guid userId, ExpenseCreateDto request, CancellationToken cancellationToken = default)
    {
        var expense = new Expense
        {
            Title = request.Title.Trim(),
            Amount = request.Amount,
            Date = request.Date,
            Category = request.Category.Trim(),
            UserId = userId
        };

        await _expenseRepository.AddAsync(expense, cancellationToken);
        await _expenseRepository.SaveChangesAsync(cancellationToken);

        return ToResponse(expense);
    }

    public async Task<bool> UpdateAsync(Guid id, Guid userId, ExpenseUpdateDto request, CancellationToken cancellationToken = default)
    {
        var expense = await _expenseRepository.GetByIdAsync(id, userId, cancellationToken);
        if (expense is null)
            return false;

        expense.Title = request.Title.Trim();
        expense.Amount = request.Amount;
        expense.Date = request.Date;
        expense.Category = request.Category.Trim();
        await _expenseRepository.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> DeleteAsync(Guid id, Guid userId, CancellationToken cancellationToken = default)
    {
        var expense = await _expenseRepository.GetByIdAsync(id, userId, cancellationToken);
        if (expense is null)
            return false;

        _expenseRepository.Remove(expense);
        await _expenseRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static ExpenseResponseDto ToResponse(Expense expense) => new()
    {
        Id = expense.Id,
        Title = expense.Title,
        Amount = expense.Amount,
        Date = expense.Date,
        Category = expense.Category
    };
}
