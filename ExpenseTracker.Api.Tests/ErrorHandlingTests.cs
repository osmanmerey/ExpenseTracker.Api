using System.Net;
using System.Net.Http.Json;
using System.Net.Sockets;
using System.Text.Json;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Errors;
using Microsoft.AspNetCore.Hosting;
using Npgsql;
using Xunit;

namespace ExpenseTracker.Api.Tests;

public class ErrorHandlingTests : IClassFixture<ApiWebApplicationFactory>
{
    private readonly ApiWebApplicationFactory _factory;

    public ErrorHandlingTests(ApiWebApplicationFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task ValidationError_ReturnsProblemDetailsWithErrorsAndTraceId()
    {
        var client = _factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/auth/login", new
        {
            email = "not-an-email",
            password = ""
        });

        await ProblemDetailsAssertions.AssertValidationProblemAsync(response);
    }

    [Fact]
    public async Task WrongPassword_Returns401ProblemDetails()
    {
        var client = _factory.CreateClient();
        var email = $"err_{Guid.NewGuid():N}@example.com";
        await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Err",
            email,
            password = "P@ssw0rd123"
        });

        var response = await client.PostAsJsonAsync("/api/auth/login", new
        {
            email,
            password = "wrong-password"
        });

        await ProblemDetailsAssertions.AssertProblemAsync(
            response,
            expectedStatus: 401,
            detailContains: "şifre");
    }

    [Fact]
    public async Task MissingToken_Returns401ProblemDetails()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/expenses");

        await ProblemDetailsAssertions.AssertProblemAsync(
            response,
            expectedStatus: 401,
            detailContains: "Oturum");
    }

    [Fact]
    public async Task DuplicateEmail_Returns409ProblemDetails()
    {
        var client = _factory.CreateClient();
        var email = $"dupe_err_{Guid.NewGuid():N}@example.com";
        var payload = new { name = "Dupe", email, password = "P@ssw0rd123" };

        Assert.Equal(HttpStatusCode.Created, (await client.PostAsJsonAsync("/api/auth/register", payload)).StatusCode);

        var second = await client.PostAsJsonAsync("/api/auth/register", payload);
        await ProblemDetailsAssertions.AssertProblemAsync(
            second,
            expectedStatus: 409,
            detailContains: "e-posta");
    }

    [Fact]
    public async Task UnhandledException_Returns500ProblemDetails_WithoutStack()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/diagnostic/boom");

        await ProblemDetailsAssertions.AssertProblemAsync(
            response,
            expectedStatus: 500,
            detailContains: "Beklenmeyen");

        var body = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("Intentional test failure", body);
    }

    [Fact]
    public async Task DatabaseUnavailableStyleException_Returns503ProblemDetails()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/diagnostic/db-down");

        await ProblemDetailsAssertions.AssertProblemAsync(
            response,
            expectedStatus: 503,
            detailContains: "kullanılamıyor");
    }

    [Fact]
    public async Task Health_ReturnsSuccess()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public void IsServiceUnavailable_UniqueViolation_IsNot503()
    {
        // 23505 = unique_violation — data error, not outage.
        var ex = new PostgresException("duplicate key", "ERROR", "ERROR", "23505");
        Assert.False(GlobalExceptionHandler.IsServiceUnavailable(ex));
    }

    [Fact]
    public void IsServiceUnavailable_ConnectionSqlState_Is503()
    {
        var ex = new PostgresException("connection failure", "ERROR", "ERROR", "08006");
        Assert.True(GlobalExceptionHandler.IsServiceUnavailable(ex));
    }

    [Fact]
    public void IsServiceUnavailable_SocketException_Is503()
    {
        Assert.True(GlobalExceptionHandler.IsServiceUnavailable(new SocketException(10061)));
    }
}

/// <summary>
/// Factory with a very low auth rate limit so 429 can be asserted in isolation.
/// </summary>
public class RateLimitWebApplicationFactory : ApiWebApplicationFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseSetting(ConfigurationKeys.AuthRateLimitPermitLimit, "2");
        builder.UseSetting(ConfigurationKeys.AuthRateLimitWindowSeconds, "60");
    }
}

public class RateLimitErrorTests : IClassFixture<RateLimitWebApplicationFactory>
{
    private readonly RateLimitWebApplicationFactory _factory;

    public RateLimitErrorTests(RateLimitWebApplicationFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task AuthRateLimit_Returns429ProblemDetailsWithRetryAfter()
    {
        var client = _factory.CreateClient();
        HttpResponseMessage? last = null;

        for (var i = 0; i < 5; i++)
        {
            last = await client.PostAsJsonAsync("/api/auth/login", new
            {
                email = "rate@example.com",
                password = "whatever1"
            });
            if (last.StatusCode == HttpStatusCode.TooManyRequests)
                break;
        }

        Assert.NotNull(last);
        await ProblemDetailsAssertions.AssertProblemAsync(
            last!,
            expectedStatus: 429,
            detailContains: "deneme");

        Assert.True(last!.Headers.Contains("Retry-After") ||
                    last.Headers.TryGetValues("Retry-After", out _));

        var body = await last.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(body);
        Assert.True(
            doc.RootElement.TryGetProperty("retryAfterSeconds", out _) ||
            body.Contains("retryAfterSeconds", StringComparison.OrdinalIgnoreCase));
    }
}
