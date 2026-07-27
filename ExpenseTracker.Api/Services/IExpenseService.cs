using ExpenseTracker.Api.DTOs;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Business logic for the authenticated user's expenses. Every method is
/// scoped by <c>userId</c> to enforce per-user isolation; talks to
/// persistence only through <see cref="Repositories.IExpenseRepository"/>.
/// </summary>
public interface IExpenseService
{
    Task<IEnumerable<ExpenseResponseDto>> GetAllAsync(Guid userId);

    Task<ExpenseResponseDto?> GetByIdAsync(Guid id, Guid userId);

    Task<ExpenseResponseDto> CreateAsync(Guid userId, ExpenseCreateDto request);

    Task<bool> UpdateAsync(Guid id, Guid userId, ExpenseUpdateDto request);

    Task<bool> DeleteAsync(Guid id, Guid userId);
}
