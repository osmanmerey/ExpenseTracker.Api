using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Errors;
using ExpenseTracker.Api.Services;
using ExpenseTracker.Api.Services.Results;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class BudgetsController : ControllerBase
{
    private readonly IBudgetService _budgetService;

    public BudgetsController(IBudgetService budgetService)
    {
        _budgetService = budgetService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<BudgetResponseDto>>> GetBudgets(
        [FromQuery] int? year,
        [FromQuery] int? month,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var now = DateTime.UtcNow;
        var y = year ?? now.Year;
        var m = month ?? now.Month;

        // Query params (no DTO) — same bounds as BudgetCreateDto [Range].
        if (m is < ValidationConstants.MinBudgetMonth or > ValidationConstants.MaxBudgetMonth)
            return this.ProblemResult(StatusCodes.Status400BadRequest, "Bad Request", ErrorMessages.BudgetMonthOutOfRange);

        if (y is < ValidationConstants.MinBudgetYear or > ValidationConstants.MaxBudgetYear)
            return this.ProblemResult(StatusCodes.Status400BadRequest, "Bad Request", ErrorMessages.BudgetYearOutOfRange);

        return Ok(await _budgetService.GetForPeriodAsync(userId, y, m, cancellationToken));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<BudgetResponseDto>> GetBudget(Guid id, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var budget = await _budgetService.GetByIdAsync(id, userId, cancellationToken);
        return budget is null
            ? this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound)
            : Ok(budget);
    }

    [HttpPost]
    public async Task<ActionResult<BudgetResponseDto>> PostBudget(
        BudgetCreateDto request,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var (budget, error) = await _budgetService.CreateAsync(userId, request, cancellationToken);
        if (error == BudgetWriteError.DuplicateCategoryMonth)
            return this.ProblemResult(
                StatusCodes.Status409Conflict,
                "Conflict",
                ErrorMessages.BudgetDuplicateCategoryMonth);

        return CreatedAtAction(nameof(GetBudget), new { id = budget!.Id }, budget);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> PutBudget(
        Guid id,
        BudgetUpdateDto request,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var (found, error) = await _budgetService.UpdateAsync(id, userId, request, cancellationToken);
        if (!found)
            return this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound);
        if (error == BudgetWriteError.DuplicateCategoryMonth)
            return this.ProblemResult(
                StatusCodes.Status409Conflict,
                "Conflict",
                ErrorMessages.BudgetDuplicateCategoryMonth);

        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteBudget(Guid id, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var deleted = await _budgetService.DeleteAsync(id, userId, cancellationToken);
        return deleted
            ? NoContent()
            : this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound);
    }

    private bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
