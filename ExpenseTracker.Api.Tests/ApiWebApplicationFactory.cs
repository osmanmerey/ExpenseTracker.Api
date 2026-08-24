using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace ExpenseTracker.Api.Tests;

/// <summary>
/// Boots the real API host but swaps the Npgsql database for an isolated
/// in-memory EF Core database and supplies test JWT/connection configuration,
/// so the full request pipeline (auth, authorization, controllers) is exercised
/// without an external PostgreSQL instance.
/// </summary>
public class ApiWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _databaseName = "ExpenseTrackerTests_" + Guid.NewGuid();

    public ApiWebApplicationFactory()
    {
        // Program.cs validates these during startup (before the web-host config
        // hooks run), so they must be present as environment variables that
        // WebApplication.CreateBuilder reads up front.
        Environment.SetEnvironmentVariable(
            "ConnectionStrings__DefaultConnection", "InMemory-Testing");
        Environment.SetEnvironmentVariable(
            "Jwt__Key",
            "test-signing-key-that-is-at-least-64-bytes-long-for-hmac-sha512-1234567890");
        Environment.SetEnvironmentVariable("Jwt__Issuer", "ExpenseTracker.Api");
        Environment.SetEnvironmentVariable("Jwt__Audience", "ExpenseTracker.Client");

        // The production default (5 requests/60s per IP) exists to slow down brute-force
        // login/register attempts. Every test in this run shares the same loopback IP via
        // TestServer, so it must be raised well above the number of auth calls any single
        // test class makes, or unrelated tests would start failing with 429 Too Many Requests.
        Environment.SetEnvironmentVariable("RateLimiting__AuthPermitLimit", "1000");
        // Dev/test aid only — Production fails fast if this is true (see Program.cs).
        Environment.SetEnvironmentVariable("Auth__ExposeResetTokenInResponse", "true");
        Environment.SetEnvironmentVariable("Auth__BootstrapAdminEmails__0", "admin@test.com");
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment(HostingEnvironments.Testing);

        // ConfigureTestServices runs after Program.cs registrations, so removing
        // every AppDbContext / DbContextOptions descriptor here strips the Npgsql
        // provider before the in-memory provider is registered. Otherwise EF Core
        // rejects having two providers in one service provider.
        builder.ConfigureTestServices(services =>
        {
            var toRemove = services.Where(d =>
                (d.ServiceType.FullName?.Contains("DbContextOptions") ?? false) ||
                (d.ServiceType.FullName?.Contains("AppDbContext") ?? false))
                .ToList();

            foreach (var descriptor in toRemove)
                services.Remove(descriptor);

            services.AddDbContext<AppDbContext>(options =>
                options.UseInMemoryDatabase(_databaseName));
        });
    }
}
