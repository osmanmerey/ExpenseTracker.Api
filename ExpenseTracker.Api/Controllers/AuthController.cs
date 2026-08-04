using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Errors;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[EnableRateLimiting(RateLimitPolicies.Auth)]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(UserRegisterDto request, CancellationToken cancellationToken)
    {
        var result = await _authService.RegisterAsync(request, cancellationToken);
        if (result.EmailAlreadyExists)
            return this.ProblemResult(
                StatusCodes.Status409Conflict,
                "Conflict",
                ErrorMessages.EmailAlreadyExists);

        return StatusCode(StatusCodes.Status201Created, result.User);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(UserLoginDto request, CancellationToken cancellationToken)
    {
        var result = await _authService.LoginAsync(request, cancellationToken);
        if (!result.Succeeded)
            return this.ProblemResult(
                StatusCodes.Status401Unauthorized,
                "Unauthorized",
                ErrorMessages.InvalidCredentials);

        return Ok(new { token = result.Token, user = result.User });
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(
        ForgotPasswordDto request,
        CancellationToken cancellationToken)
    {
        var env = HttpContext.RequestServices.GetRequiredService<IHostEnvironment>();
        // Development/Testing return the token so clients can complete reset without email.
        var includeToken = env.IsDevelopment() || env.IsEnvironment("Testing");

        var result = await _authService.ForgotPasswordAsync(
            request,
            includeToken,
            cancellationToken);

        return Ok(new
        {
            message = result.Message,
            resetToken = result.ResetToken
        });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(
        ResetPasswordDto request,
        CancellationToken cancellationToken)
    {
        var result = await _authService.ResetPasswordAsync(request, cancellationToken);
        if (!result.Succeeded)
            return this.ProblemResult(
                StatusCodes.Status400BadRequest,
                "Bad Request",
                ErrorMessages.InvalidResetToken);

        return Ok(new { message = "Şifreniz güncellendi. Yeni şifrenizle giriş yapabilirsiniz." });
    }
}
