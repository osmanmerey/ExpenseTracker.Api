using ExpenseTracker.Api.DTOs;
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
    public async Task<ActionResult<IEnumerable<ExpenseResponseDto>>> GetExpenses()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        return Ok(await _expenseService.GetAllAsync(userId));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ExpenseResponseDto>> GetExpense(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = await _expenseService.GetByIdAsync(id, userId);
        return expense is null ? NotFound() : Ok(expense);
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseResponseDto>> PostExpense(ExpenseCreateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = await _expenseService.CreateAsync(userId, request);
        return CreatedAtAction(nameof(GetExpense), new { id = expense.Id }, expense);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> PutExpense(Guid id, ExpenseUpdateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var updated = await _expenseService.UpdateAsync(id, userId, request);
        return updated ? NoContent() : NotFound();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteExpense(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var deleted = await _expenseService.DeleteAsync(id, userId);
        return deleted ? NoContent() : NotFound();
    }

    private bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
