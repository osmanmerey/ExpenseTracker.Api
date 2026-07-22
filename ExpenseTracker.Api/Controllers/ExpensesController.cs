using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ExpensesController : ControllerBase
{
    private readonly AppDbContext _context;

    public ExpensesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ExpenseResponseDto>>> GetExpenses()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        return await _context.Expenses
            .AsNoTracking()
            .Where(e => e.UserId == userId)
            .OrderByDescending(e => e.Date)
            .Select(e => ToResponse(e))
            .ToListAsync();
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ExpenseResponseDto>> GetExpense(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = await _context.Expenses
            .AsNoTracking()
            .Where(e => e.Id == id && e.UserId == userId)
            .Select(e => ToResponse(e))
            .FirstOrDefaultAsync();

        return expense is null ? NotFound() : Ok(expense);
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseResponseDto>> PostExpense(ExpenseCreateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = new Expense
        {
            Title = request.Title.Trim(),
            Amount = request.Amount,
            Date = request.Date,
            Category = request.Category.Trim(),
            UserId = userId
        };

        _context.Expenses.Add(expense);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetExpense), new { id = expense.Id }, ToResponse(expense));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> PutExpense(Guid id, ExpenseUpdateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = await _context.Expenses
            .FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);

        if (expense is null)
            return NotFound();

        expense.Title = request.Title.Trim();
        expense.Amount = request.Amount;
        expense.Date = request.Date;
        expense.Category = request.Category.Trim();
        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteExpense(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var expense = await _context.Expenses
            .FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);

        if (expense is null)
            return NotFound();

        _context.Expenses.Remove(expense);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private bool TryGetUserId(out Guid userId)
    {
        return Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
    }

    private static ExpenseResponseDto ToResponse(Expense expense)
    {
        return new ExpenseResponseDto
        {
            Id = expense.Id,
            Title = expense.Title,
            Amount = expense.Amount,
            Date = expense.Date,
            Category = expense.Category
        };
    }
}