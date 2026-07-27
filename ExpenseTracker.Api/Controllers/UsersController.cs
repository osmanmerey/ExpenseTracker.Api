using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Services;
using ExpenseTracker.Api.Services.Results;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserResponseDto>> GetCurrentUser()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var user = await _userService.GetCurrentUserAsync(userId);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateCurrentUser(UserUpdateDto request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var outcome = await _userService.UpdateCurrentUserAsync(userId, request);
        return outcome switch
        {
            UserUpdateOutcome.EmailAlreadyExists => Conflict("Bu e-posta adresi zaten kullanılıyor."),
            UserUpdateOutcome.NotFound => NotFound(),
            _ => NoContent()
        };
    }

    [HttpDelete("me")]
    public async Task<IActionResult> DeleteCurrentUser()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized();

        var deleted = await _userService.DeleteCurrentUserAsync(userId);
        return deleted ? NoContent() : NotFound();
    }

    private bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
