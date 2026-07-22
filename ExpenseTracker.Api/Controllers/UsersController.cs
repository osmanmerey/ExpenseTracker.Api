using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserResponseDto>> GetCurrentUser()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var user = await _context.Users
            .AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => new UserResponseDto
            {
                Id = u.Id,
                Name = u.Name,
                Email = u.Email
            })
            .FirstOrDefaultAsync();

        return user is null ? NotFound() : Ok(user);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateCurrentUser(UserUpdateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _context.Users.AnyAsync(u => u.Email == normalizedEmail && u.Id != userId))
            return Conflict("Bu e-posta adresi zaten kullanılıyor.");

        var user = await _context.Users.FindAsync(userId);
        if (user is null)
            return NotFound();

        user.Name = request.Name.Trim();
        user.Email = normalizedEmail;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("me")]
    public async Task<IActionResult> DeleteCurrentUser()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var user = await _context.Users.FindAsync(userId);
        if (user is null)
            return NotFound();

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private bool TryGetUserId(out Guid userId)
    {
        return Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
    }
}