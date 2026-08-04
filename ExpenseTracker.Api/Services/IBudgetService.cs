using ExpenseTracker.Api.DTOs;

namespace ExpenseTracker.Api.Services;

public interface IBudgetService
{
    Task<IEnumerable<BudgetResponseDto>> GetForPeriodAsync(
        Guid userId,
        int year,
        int month,
        CancellationToken cancellationToken = default);

    Task<BudgetResponseDto?> GetByIdAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);

    Task<(BudgetResponseDto? Budget, string? Error)> CreateAsync(
        Guid userId,
        BudgetCreateDto request,
        CancellationToken cancellationToken = default);

    Task<(bool Found, string? Error)> UpdateAsync(
        Guid id,
        Guid userId,
        BudgetUpdateDto request,
        CancellationToken cancellationToken = default);

    Task<bool> DeleteAsync(Guid id, Guid userId, CancellationToken cancellationToken = default);
}
