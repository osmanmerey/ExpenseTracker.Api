using System.Collections.Concurrent;
using System.Security.Cryptography;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Process-local reset tokens. Cleared on app restart by design (no durable store / email yet).
/// Expired entries are purged opportunistically and on a background timer.
/// </summary>
public sealed class InMemoryPasswordResetStore : IPasswordResetStore, IDisposable
{
    private readonly ConcurrentDictionary<string, (string Token, DateTime ExpiresUtc)> _tokens = new();
    private readonly Timer _cleanupTimer;

    public InMemoryPasswordResetStore()
    {
        _cleanupTimer = new Timer(
            _ => PurgeExpired(),
            null,
            TimeSpan.FromMinutes(5),
            TimeSpan.FromMinutes(5));
    }

    public string CreateToken(string normalizedEmail, TimeSpan lifetime)
    {
        PurgeExpired();
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

    private void PurgeExpired()
    {
        var now = DateTime.UtcNow;
        foreach (var pair in _tokens)
        {
            if (pair.Value.ExpiresUtc < now)
                _tokens.TryRemove(pair.Key, out _);
        }
    }

    public void Dispose() => _cleanupTimer.Dispose();
}
