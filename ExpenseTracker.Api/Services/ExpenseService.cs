using ExpenseTracker.Api.Common;
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
        var (title, currency) = ResolveTitleAndCurrency(request.Title, request.Currency);

        var expense = new Expense
        {
            Title = title,
            Amount = request.Amount,
            Date = NormalizeExpenseDate(request.Date),
            Category = CategoryNormalizer.Display(request.Category),
            Currency = currency,
            Kind = request.Kind,
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

        var (title, currency) = ResolveTitleAndCurrency(request.Title, request.Currency);
        expense.Title = title;
        expense.Amount = request.Amount;
        expense.Date = NormalizeExpenseDate(request.Date);
        expense.Category = CategoryNormalizer.Display(request.Category);
        expense.Currency = currency;
        expense.Kind = request.Kind;
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

    /// <summary>
    /// Accepts plain title + currency, or legacy <c>[USD] title</c> when currency omitted.
    /// </summary>
    private static (string Title, string Currency) ResolveTitleAndCurrency(string title, string? currency)
    {
        if (!string.IsNullOrWhiteSpace(currency))
        {
            return (
                FixedCurrencyRates.StripCurrencyPrefix(title),
                FixedCurrencyRates.Normalize(currency));
        }

        var fromTitle = FixedCurrencyRates.ParseCurrencyCodeFromTitle(title);
        return (FixedCurrencyRates.StripCurrencyPrefix(title), fromTitle);
    }

    private static DateTime NormalizeExpenseDate(DateTime date) =>
        new(date.Year, date.Month, date.Day, 12, 0, 0, DateTimeKind.Utc);

    private static ExpenseResponseDto ToResponse(Expense expense) => new()
    {
        Id = expense.Id,
        Title = expense.Title,
        Amount = expense.Amount,
        Date = expense.Date,
        Category = expense.Category,
        Currency = expense.Currency,
        Kind = expense.Kind
    };
}
