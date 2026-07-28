using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(UserRegisterDto request)
    {
        var result = await _authService.RegisterAsync(request);
        if (result.EmailAlreadyExists)
            return Conflict(ErrorMessages.EmailAlreadyExists);

        return StatusCode(StatusCodes.Status201Created, result.User);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(UserLoginDto request)
    {
        var result = await _authService.LoginAsync(request);
        if (!result.Succeeded)
            return Unauthorized(ErrorMessages.InvalidCredentials);

        return Ok(new { token = result.Token, user = result.User });
    }
}
