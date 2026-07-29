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
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserResponseDto>> GetCurrentUser(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var user = await _userService.GetCurrentUserAsync(userId, cancellationToken);
        return user is null
            ? this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound)
            : Ok(user);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateCurrentUser(UserUpdateDto request, CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var outcome = await _userService.UpdateCurrentUserAsync(userId, request, cancellationToken);
        return outcome switch
        {
            UserUpdateOutcome.EmailAlreadyExists => this.ProblemResult(
                StatusCodes.Status409Conflict, "Conflict", ErrorMessages.EmailAlreadyExists),
            UserUpdateOutcome.NotFound => this.ProblemResult(
                StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound),
            _ => NoContent()
        };
    }

    [HttpDelete("me")]
    public async Task<IActionResult> DeleteCurrentUser(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
            return this.ProblemResult(StatusCodes.Status401Unauthorized, "Unauthorized", ErrorMessages.Unauthorized);

        var deleted = await _userService.DeleteCurrentUserAsync(userId, cancellationToken);
        return deleted
            ? NoContent()
            : this.ProblemResult(StatusCodes.Status404NotFound, "Not Found", ErrorMessages.NotFound);
    }

    private bool TryGetUserId(out Guid userId) =>
        Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
}
