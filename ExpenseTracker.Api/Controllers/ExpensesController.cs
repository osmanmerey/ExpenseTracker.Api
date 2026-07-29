using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Errors;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ExpensesController : ControllerBase
{
    private readonly IExpenseService _expenseService;

    public ExpensesController(IExpenseService expenseService)
    {
        _expenseService = expenseService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ExpenseResponseDto>>> GetExpenses(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        return Ok(await _expenseService.GetAllAsync(userId, cancellationToken));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ExpenseResponseDto>> GetExpense(Guid id, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var expense = await _expenseService.GetByIdAsync(id, userId, cancellationToken);
        return expense is null
            ? this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound)
            : Ok(expense);
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseResponseDto>> PostExpense(ExpenseCreateDto request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var expense = await _expenseService.CreateAsync(userId, request, cancellationToken);
        return CreatedAtAction(nameof(GetExpense), new { id = expense.Id }, expense);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> PutExpense(Guid id, ExpenseUpdateDto request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var updated = await _expenseService.UpdateAsync(id, userId, request, cancellationToken);
        return updated
            ? NoContent()
            : this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteExpense(Guid id, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var deleted = await _expenseService.DeleteAsync(id, userId, cancellationToken);
        return deleted
            ? NoContent()
            : this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound);
    }

    private bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
