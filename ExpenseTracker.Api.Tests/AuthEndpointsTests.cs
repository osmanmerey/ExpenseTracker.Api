using System.Net;
using System.Net.Http.Json;
using Xunit;

namespace ExpenseTracker.Api.Tests;

public class AuthEndpointsTests : IClassFixture<ApiWebApplicationFactory>
{
    private readonly ApiWebApplicationFactory _factory;

    public AuthEndpointsTests(ApiWebApplicationFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Register_ReturnsCreated_AndDoesNotLeakPasswordHash()
    {
        var client = _factory.CreateClient();
        var email = $"register_{Guid.NewGuid():N}@example.com";

        var response = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Register User",
            email,
            password = "P@ssw0rd123"
        });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var body = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("passwordHash", body, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Register_WithDuplicateEmail_ReturnsConflict()
    {
        var client = _factory.CreateClient();
        var email = $"dupe_{Guid.NewGuid():N}@example.com";
        var payload = new { name = "Dupe", email, password = "P@ssw0rd123" };

        var first = await client.PostAsJsonAsync("/api/auth/register", payload);
        Assert.Equal(HttpStatusCode.Created, first.StatusCode);

        var second = await client.PostAsJsonAsync("/api/auth/register", payload);
        Assert.Equal(HttpStatusCode.Conflict, second.StatusCode);
    }

    [Fact]
    public async Task Register_WithInvalidInput_ReturnsBadRequest()
    {
        var client = _factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "",
            email = "not-an-email",
            password = "short"
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Login_WithValidCredentials_ReturnsToken()
    {
        var client = _factory.CreateClient();
        var email = $"login_{Guid.NewGuid():N}@example.com";
        await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Login User",
            email,
            password = "P@ssw0rd123"
        });

        var response = await client.PostAsJsonAsync("/api/auth/login", new
        {
            email,
            password = "P@ssw0rd123"
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var payload = await response.Content.ReadFromJsonAsync<LoginResponse>();
        Assert.NotNull(payload);
        Assert.False(string.IsNullOrWhiteSpace(payload!.Token));
        Assert.NotEqual(Guid.Empty, payload.User.Id);
    }

    [Fact]
    public async Task Login_WithWrongPassword_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var email = $"wrongpw_{Guid.NewGuid():N}@example.com";
        await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Wrong Pw",
            email,
            password = "P@ssw0rd123"
        });

        var response = await client.PostAsJsonAsync("/api/auth/login", new
        {
            email,
            password = "wrong-password"
        });

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
