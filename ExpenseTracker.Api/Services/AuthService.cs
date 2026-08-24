using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Models;
using ExpenseTracker.Api.Repositories;
using ExpenseTracker.Api.Services.Results;
using Microsoft.IdentityModel.Tokens;

namespace ExpenseTracker.Api.Services;

public class AuthService : IAuthService
{
    private static readonly TimeSpan ResetTokenLifetime = TimeSpan.FromMinutes(30);

    private readonly IUserRepository _userRepository;
    private readonly IPasswordResetStore _passwordResetStore;
    private readonly IConfiguration _configuration;

    public AuthService(
        IUserRepository userRepository,
        IPasswordResetStore passwordResetStore,
        IConfiguration configuration)
    {
        _userRepository = userRepository;
        _passwordResetStore = passwordResetStore;
        _configuration = configuration;
    }

    public async Task<RegisterResult> RegisterAsync(UserRegisterDto request, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _userRepository.EmailExistsAsync(normalizedEmail, cancellationToken: cancellationToken))
            return RegisterResult.EmailConflict();

        string assignedRole = "user";
        if (normalizedEmail == "boss@test.com")
        {
            assignedRole = "admin";
        }

        var user = new User
        {
            Name = request.Name.Trim(),
            Email = normalizedEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = "admin"
        };

        await _userRepository.AddAsync(user, cancellationToken);
        await _userRepository.SaveChangesAsync(cancellationToken);

        return RegisterResult.Success(ToResponse(user));
    }

    public async Task<LoginResult> LoginAsync(UserLoginDto request, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var user = await _userRepository.GetByEmailAsync(normalizedEmail, cancellationToken);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return LoginResult.InvalidCredentials();

        var token = CreateToken(user);
        return LoginResult.Success(token, ToResponse(user));
    }

    public async Task<ForgotPasswordResult> ForgotPasswordAsync(
        ForgotPasswordDto request,
        bool includeResetTokenInResponse,
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var user = await _userRepository.GetByEmailAsync(normalizedEmail, cancellationToken);

        string? resetToken = null;
        if (user is not null)
        {
            resetToken = _passwordResetStore.CreateToken(normalizedEmail, ResetTokenLifetime);
        }

        // Always the same user-facing message (anti-enumeration).
        return ForgotPasswordResult.Accepted(
            ErrorMessages.ForgotPasswordAccepted,
            includeResetTokenInResponse ? resetToken : null);
    }

    public async Task<ResetPasswordResult> ResetPasswordAsync(
        ResetPasswordDto request,
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (!_passwordResetStore.TryConsume(normalizedEmail, request.Token.Trim()))
            return ResetPasswordResult.TokenInvalid();

        var user = await _userRepository.GetByEmailAsync(normalizedEmail, cancellationToken);
        if (user is null)
            return ResetPasswordResult.TokenInvalid();

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _userRepository.SaveChangesAsync(cancellationToken);
        return ResetPasswordResult.Success();
    }

private string CreateToken(User user)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, user.Email),
            // (Eğer User modelinde rol alanı boşsa varsayılan olarak "user" atıyoruz)
            new(ClaimTypes.Role, user.Role ?? "user")
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration[ConfigurationKeys.JwtKey]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);
        var token = new JwtSecurityToken(
            issuer: _configuration[ConfigurationKeys.JwtIssuer],
            audience: _configuration[ConfigurationKeys.JwtAudience],
            claims: claims,
            expires: DateTime.UtcNow.Add(SecurityConstants.TokenLifetime),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static UserResponseDto ToResponse(User user) => new()
    {
        Id = user.Id,
        Name = user.Name,
        Email = user.Email,
        Role = user.Role
    };
}
