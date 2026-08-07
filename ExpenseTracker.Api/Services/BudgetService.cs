using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Models;
using ExpenseTracker.Api.Repositories;
using ExpenseTracker.Api.Services.Results;

namespace ExpenseTracker.Api.Services;

public class BudgetService : IBudgetService
{
    private readonly IBudgetRepository _budgetRepository;
    private readonly IExpenseRepository _expenseRepository;

    public BudgetService(IBudgetRepository budgetRepository, IExpenseRepository expenseRepository)
    {
        _budgetRepository = budgetRepository;
        _expenseRepository = expenseRepository;
    }

    public async Task<IEnumerable<BudgetResponseDto>> GetForPeriodAsync(
        Guid userId,
        int year,
        int month,
        CancellationToken cancellationToken = default)
    {
        var budgets = await _budgetRepository.GetForUserPeriodNoTrackingAsync(
            userId, year, month, cancellationToken);
        var spentByCategory = await GetSpentByCategoryAsync(userId, year, month, cancellationToken);

        return budgets.Select(b => ToResponse(b, spentByCategory));
    }

    public async Task<BudgetResponseDto?> GetByIdAsync(
        Guid id,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var budget = await _budgetRepository.GetByIdNoTrackingAsync(id, userId, cancellationToken);
        if (budget is null)
            return null;

        var spentByCategory = await GetSpentByCategoryAsync(
            userId, budget.Year, budget.Month, cancellationToken);
        return ToResponse(budget, spentByCategory);
    }

    public async Task<(BudgetResponseDto? Budget, BudgetWriteError Error)> CreateAsync(
        Guid userId,
        BudgetCreateDto request,
        CancellationToken cancellationToken = default)
    {
        var category = CategoryNormalizer.Display(request.Category);
        var exists = await _budgetRepository.ExistsForPeriodAsync(
            userId, request.Year, request.Month, category, null, cancellationToken);
        if (exists)
            return (null, BudgetWriteError.DuplicateCategoryMonth);

        var budget = new Budget
        {
            UserId = userId,
            Category = category,
            LimitAmount = request.LimitAmount,
            Year = request.Year,
            Month = request.Month
        };

        await _budgetRepository.AddAsync(budget, cancellationToken);
        await _budgetRepository.SaveChangesAsync(cancellationToken);

        var spentByCategory = await GetSpentByCategoryAsync(
            userId, budget.Year, budget.Month, cancellationToken);
        return (ToResponse(budget, spentByCategory), BudgetWriteError.None);
    }

    public async Task<(bool Found, BudgetWriteError Error)> UpdateAsync(
        Guid id,
        Guid userId,
        BudgetUpdateDto request,
        CancellationToken cancellationToken = default)
    {
        var budget = await _budgetRepository.GetByIdAsync(id, userId, cancellationToken);
        if (budget is null)
            return (false, BudgetWriteError.None);

        var category = CategoryNormalizer.Display(request.Category);
        var exists = await _budgetRepository.ExistsForPeriodAsync(
            userId, request.Year, request.Month, category, id, cancellationToken);
        if (exists)
            return (true, BudgetWriteError.DuplicateCategoryMonth);

        budget.Category = category;
        budget.LimitAmount = request.LimitAmount;
        budget.Year = request.Year;
        budget.Month = request.Month;
        await _budgetRepository.SaveChangesAsync(cancellationToken);
        return (true, BudgetWriteError.None);
    }

    public async Task<bool> DeleteAsync(Guid id, Guid userId, CancellationToken cancellationToken = default)
    {
        var budget = await _budgetRepository.GetByIdAsync(id, userId, cancellationToken);
        if (budget is null)
            return false;

        _budgetRepository.Remove(budget);
        await _budgetRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private async Task<Dictionary<string, decimal>> GetSpentByCategoryAsync(
        Guid userId,
        int year,
        int month,
        CancellationToken cancellationToken)
    {
        var start = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
        var end = start.AddMonths(1);

        var expenses = await _expenseRepository.GetForUserInDateRangeNoTrackingAsync(
            userId, start, end, cancellationToken);

        var byCategory = new Dictionary<string, decimal>(StringComparer.Ordinal);
        decimal total = 0;

        foreach (var expense in expenses.Where(e => e.Kind == TransactionKind.Expense))
        {
            var amountTry = FixedCurrencyRates.ToTry(
                expense.Amount, expense.Currency, expense.Title);
            total += amountTry;
            var key = CategoryNormalizer.Key(expense.Category);
            byCategory[key] = byCategory.GetValueOrDefault(key) + amountTry;
        }

        byCategory[string.Empty] = total;
        return byCategory;
    }

    private static BudgetResponseDto ToResponse(Budget budget, IReadOnlyDictionary<string, decimal> spentByCategory)
    {
        var key = CategoryNormalizer.Key(budget.Category);
        spentByCategory.TryGetValue(key, out var spent);
        if (string.IsNullOrEmpty(key))
            spent = spentByCategory.GetValueOrDefault(string.Empty);

        return new BudgetResponseDto
        {
            Id = budget.Id,
            Category = budget.Category,
            LimitAmount = budget.LimitAmount,
            Year = budget.Year,
            Month = budget.Month,
            SpentAmount = spent
        };
    }
}
