using ExpenseTracker.Api.DTOs;

namespace ExpenseTracker.Api.Services.Results;

/// <summary>Outcome of <see cref="IAuthService.RegisterAsync"/>, decoupled from HTTP concerns.</summary>
public class RegisterResult
{
    public bool Succeeded { get; private init; }
    public bool EmailAlreadyExists { get; private init; }
    public UserResponseDto? User { get; private init; }

    public static RegisterResult Success(UserResponseDto user) =>
        new() { Succeeded = true, User = user };

    public static RegisterResult EmailConflict() =>
        new() { Succeeded = false, EmailAlreadyExists = true };
}

/// <summary>Outcome of <see cref="IAuthService.LoginAsync"/>, decoupled from HTTP concerns.</summary>
public class LoginResult
{
    public bool Succeeded { get; private init; }
    public string? Token { get; private init; }
    public UserResponseDto? User { get; private init; }

    public static LoginResult Success(string token, UserResponseDto user) =>
        new() { Succeeded = true, Token = token, User = user };

    public static LoginResult InvalidCredentials() => new() { Succeeded = false };
}
