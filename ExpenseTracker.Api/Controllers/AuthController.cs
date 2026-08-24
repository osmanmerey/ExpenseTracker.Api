using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Errors;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace ExpenseTracker.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[EnableRateLimiting(RateLimitPolicies.Auth)]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IConfiguration _configuration;

    public AuthController(IAuthService authService, IConfiguration configuration)
    {
        _authService = authService;
        _configuration = configuration;
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

    /// <summary>
    /// Issues a reset token. Without email delivery this is a development aid only —
    /// production must send the token out-of-band and keep Auth:ExposeResetTokenInResponse=false.
    /// </summary>
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(
        ForgotPasswordDto request,
        CancellationToken cancellationToken)
    {
        var includeToken = _configuration.GetValue(
            ConfigurationKeys.AuthExposeResetTokenInResponse, false);

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
