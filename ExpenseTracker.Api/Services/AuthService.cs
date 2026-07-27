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
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;

    public AuthService(IUserRepository userRepository, IConfiguration configuration)
    {
        _userRepository = userRepository;
        _configuration = configuration;
    }

    public async Task<RegisterResult> RegisterAsync(UserRegisterDto request)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _userRepository.EmailExistsAsync(normalizedEmail))
            return RegisterResult.EmailConflict();

        var user = new User
        {
            Name = request.Name.Trim(),
            Email = normalizedEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password)
        };

        await _userRepository.AddAsync(user);
        await _userRepository.SaveChangesAsync();

        return RegisterResult.Success(ToResponse(user));
    }

    public async Task<LoginResult> LoginAsync(UserLoginDto request)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var user = await _userRepository.GetByEmailAsync(normalizedEmail);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return LoginResult.InvalidCredentials();

        var token = CreateToken(user);
        return LoginResult.Success(token, ToResponse(user));
    }

    private string CreateToken(User user)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, user.Email)
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
        Email = user.Email
    };
}
