using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Services.Results;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Business logic for registration and login: password hashing/verification,
/// uniqueness rules and JWT issuance. Talks to persistence only through
/// <see cref="Repositories.IUserRepository"/>.
/// </summary>
public interface IAuthService
{
    Task<RegisterResult> RegisterAsync(UserRegisterDto request, CancellationToken cancellationToken = default);

    Task<LoginResult> LoginAsync(UserLoginDto request, CancellationToken cancellationToken = default);
}
