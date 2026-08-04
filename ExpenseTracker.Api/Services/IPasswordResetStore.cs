namespace ExpenseTracker.Api.Services;

/// <summary>
/// Short-lived reset tokens (in-memory). Suitable for Development / InMemory demos
/// without an email provider. Production would use email delivery instead of returning tokens.
/// </summary>
public interface IPasswordResetStore
{
    string CreateToken(string normalizedEmail, TimeSpan lifetime);

    bool TryConsume(string normalizedEmail, string token);
}
