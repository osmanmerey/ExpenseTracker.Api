using System.Collections.Concurrent;
using System.Security.Cryptography;

namespace ExpenseTracker.Api.Services;

public sealed class InMemoryPasswordResetStore : IPasswordResetStore
{
    private readonly ConcurrentDictionary<string, (string Token, DateTime ExpiresUtc)> _tokens = new();

    public string CreateToken(string normalizedEmail, TimeSpan lifetime)
    {
        var token = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
        _tokens[normalizedEmail] = (token, DateTime.UtcNow.Add(lifetime));
        return token;
    }

    public bool TryConsume(string normalizedEmail, string token)
    {
        if (!_tokens.TryGetValue(normalizedEmail, out var entry))
            return false;

        if (entry.ExpiresUtc < DateTime.UtcNow)
        {
            _tokens.TryRemove(normalizedEmail, out _);
            return false;
        }

        if (entry.Token.Length != token.Length)
            return false;

        if (!CryptographicOperations.FixedTimeEquals(
                System.Text.Encoding.UTF8.GetBytes(entry.Token),
                System.Text.Encoding.UTF8.GetBytes(token)))
            return false;

        _tokens.TryRemove(normalizedEmail, out _);
        return true;
    }
}
