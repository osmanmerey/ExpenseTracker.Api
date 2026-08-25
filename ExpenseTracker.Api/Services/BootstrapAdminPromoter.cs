using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Data;
using Microsoft.EntityFrameworkCore;

namespace ExpenseTracker.Api.Services;

/// <summary>
/// Ensures well-known local admin mailboxes keep the admin role after the
/// security fix that stopped assigning admin to every new user.
/// </summary>
public static class BootstrapAdminPromoter
{
    public static async Task PromoteAsync(
        AppDbContext db,
        IConfiguration configuration,
        CancellationToken cancellationToken = default)
    {
        var emails = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            AuthBootstrapDefaults.DevelopmentAdminEmail
        };

        var configured = configuration.GetSection(ConfigurationKeys.AuthBootstrapAdminEmails)
            .Get<string[]>() ?? [];
        foreach (var candidate in configured)
        {
            if (!string.IsNullOrWhiteSpace(candidate))
                emails.Add(candidate.Trim());
        }

        var users = await db.Users
            .Where(user => emails.Contains(user.Email))
            .ToListAsync(cancellationToken);

        foreach (var user in users)
        {
            if (!UserRoles.IsAdmin(user.Role))
                user.Role = UserRoles.Admin;
        }

        if (db.ChangeTracker.HasChanges())
            await db.SaveChangesAsync(cancellationToken);
    }
}
