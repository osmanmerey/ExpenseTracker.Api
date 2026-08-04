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

/// <summary>Outcome of forgot-password. Always presents as accepted to avoid email enumeration.</summary>
public class ForgotPasswordResult
{
    public string Message { get; private init; } = string.Empty;

    /// <summary>Only populated in Development for local testing without email.</summary>
    public string? ResetToken { get; private init; }

    public static ForgotPasswordResult Accepted(string message, string? resetToken = null) =>
        new() { Message = message, ResetToken = resetToken };
}

public class ResetPasswordResult
{
    public bool Succeeded { get; private init; }
    public bool InvalidToken { get; private init; }

    public static ResetPasswordResult Success() => new() { Succeeded = true };

    public static ResetPasswordResult TokenInvalid() =>
        new() { Succeeded = false, InvalidToken = true };
}
