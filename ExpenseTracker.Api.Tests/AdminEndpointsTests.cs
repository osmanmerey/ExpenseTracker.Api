using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ExpenseTracker.Api.Tests;

public class AdminEndpointsTests : IDisposable
{
    private const string AdminEmail = "admin@test.com";
    private const string Password = "P@ssw0rd123";

    private readonly ApiWebApplicationFactory _factory = new();

    public void Dispose() => _factory.Dispose();

    [Fact]
    public async Task Register_AssignsUserRole_ByDefault()
    {
        var client = _factory.CreateClient();
        var email = $"member_{Guid.NewGuid():N}@example.com";

        var response = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Member",
            email,
            password = Password
        });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var user = await response.Content.ReadFromJsonAsync<UserSummary>();
        Assert.NotNull(user);
        Assert.Equal("user", user!.Role);
    }

    [Fact]
    public async Task Register_BossTestCom_IsAlwaysAdmin()
    {
        var client = _factory.CreateClient();
        var email = AuthBootstrapDefaults.DevelopmentAdminEmail;
        var register = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Boss",
            email,
            password = Password
        });
        Assert.True(
            register.StatusCode is HttpStatusCode.Created or HttpStatusCode.Conflict,
            $"Unexpected register status {register.StatusCode}: {await register.Content.ReadAsStringAsync()}");

        var login = await client.PostAsJsonAsync("/api/auth/login", new { email, password = Password });
        Assert.Equal(HttpStatusCode.OK, login.StatusCode);
        var payload = await login.Content.ReadFromJsonAsync<LoginResponse>(new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });
        Assert.Equal("admin", payload!.User.Role);
    }

    [Fact]
    public async Task Register_BootstrapAdminEmail_AssignsAdminRole()
    {
        var (_, login) = await LoginAsAdminAsync();
        Assert.Equal("admin", login.User.Role);
    }

    [Fact]
    public async Task Login_PromotesExistingBootstrapEmail_ToAdmin()
    {
        var client = _factory.CreateClient();
        var register = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "Admin",
            email = AdminEmail,
            password = Password
        });
        Assert.True(
            register.StatusCode is HttpStatusCode.Created or HttpStatusCode.Conflict,
            $"Unexpected register status {register.StatusCode}: {await register.Content.ReadAsStringAsync()}");

        using (var scope = _factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var user = await db.Users.SingleAsync(u => u.Email == AdminEmail);
            user.Role = UserRoles.User;
            await db.SaveChangesAsync();
        }

        var login = await client.PostAsJsonAsync("/api/auth/login", new { email = AdminEmail, password = Password });
        Assert.Equal(HttpStatusCode.OK, login.StatusCode);

        var payload = await login.Content.ReadFromJsonAsync<LoginResponse>(new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });
        Assert.NotNull(payload);
        Assert.Equal("admin", payload!.User.Role);
    }

    [Fact]
    public async Task GetAllUsers_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/users");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetAllUsers_AsRegularUser_ReturnsForbidden()
    {
        var (client, _) = await LoginAsUserAsync();
        var response = await client.GetAsync("/api/users");
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task GetAllUsers_AsAdmin_ReturnsUsersWithRoles()
    {
        var (adminClient, adminLogin) = await LoginAsAdminAsync();
        var (userClient, userLogin) = await LoginAsUserAsync();
        _ = userClient;

        var response = await adminClient.GetAsync("/api/users");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var users = await response.Content.ReadFromJsonAsync<List<UserSummary>>();
        Assert.NotNull(users);
        Assert.Contains(users!, u => u.Id == adminLogin.User.Id && u.Role == "admin");
        Assert.Contains(users!, u => u.Id == userLogin.User.Id && u.Role == "user");
    }

    [Fact]
    public async Task GetCurrentUser_IncludesRole()
    {
        var (client, login) = await LoginAsUserAsync();

        var response = await client.GetAsync("/api/users/me");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var me = await response.Content.ReadFromJsonAsync<UserSummary>();
        Assert.NotNull(me);
        Assert.Equal(login.User.Id, me!.Id);
        Assert.Equal("user", me.Role);
    }

    [Fact]
    public async Task GetUserExpensesByAdmin_AsRegularUser_ReturnsForbidden()
    {
        var (client, login) = await LoginAsUserAsync();
        var response = await client.GetAsync($"/api/expenses/user/{login.User.Id}");
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task GetUserExpensesByAdmin_AsAdmin_ReturnsTargetUserExpenses()
    {
        var (userClient, userLogin) = await LoginAsUserAsync();
        var create = await userClient.PostAsJsonAsync("/api/expenses", new
        {
            title = "Admin visible",
            amount = 12.5m,
            date = DateTime.UtcNow,
            category = "Food"
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var (adminClient, _) = await LoginAsAdminAsync();
        var response = await adminClient.GetAsync($"/api/expenses/user/{userLogin.User.Id}");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var expenses = await response.Content.ReadFromJsonAsync<List<ExpenseResponse>>();
        Assert.NotNull(expenses);
        Assert.Contains(expenses!, e => e.Title == "Admin visible");
    }

    [Fact]
    public async Task UpdateUserRole_AsAdmin_PromotesUser()
    {
        var (adminClient, _) = await LoginAsAdminAsync();
        var (_, userLogin) = await LoginAsUserAsync();

        var response = await adminClient.PutAsJsonAsync(
            $"/api/users/{userLogin.User.Id}/role",
            new { role = "admin" });
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

        var users = await adminClient.GetFromJsonAsync<List<UserSummary>>("/api/users");
        Assert.Contains(users!, u => u.Id == userLogin.User.Id && u.Role == "admin");
    }

    [Fact]
    public async Task UpdateUserRole_InvalidRole_ReturnsBadRequest()
    {
        var (adminClient, _) = await LoginAsAdminAsync();
        var (_, userLogin) = await LoginAsUserAsync();

        var response = await adminClient.PutAsJsonAsync(
            $"/api/users/{userLogin.User.Id}/role",
            new { role = "superadmin" });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task UpdateUserRole_LastAdmin_ReturnsConflict()
    {
        var (adminClient, adminLogin) = await LoginAsAdminAsync();

        var response = await adminClient.PutAsJsonAsync(
            $"/api/users/{adminLogin.User.Id}/role",
            new { role = "user" });
        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }

    [Fact]
    public async Task DeleteUser_AsAdmin_RemovesRegularUser()
    {
        var (adminClient, _) = await LoginAsAdminAsync();
        var (_, userLogin) = await LoginAsUserAsync();

        var response = await adminClient.DeleteAsync($"/api/users/{userLogin.User.Id}");
        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

        var users = await adminClient.GetFromJsonAsync<List<UserSummary>>("/api/users");
        Assert.DoesNotContain(users!, u => u.Id == userLogin.User.Id);
    }

    [Fact]
    public async Task DeleteUser_LastAdmin_ReturnsConflict()
    {
        var (adminClient, adminLogin) = await LoginAsAdminAsync();

        var response = await adminClient.DeleteAsync($"/api/users/{adminLogin.User.Id}");
        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }

    [Fact]
    public async Task UpdateUserRole_AsRegularUser_ReturnsForbidden()
    {
        var (client, login) = await LoginAsUserAsync();
        var response = await client.PutAsJsonAsync(
            $"/api/users/{login.User.Id}/role",
            new { role = "admin" });
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    private async Task<(HttpClient Client, LoginResponse Login)> LoginAsUserAsync()
    {
        var email = $"member_{Guid.NewGuid():N}@example.com";
        return await LoginAsync(email, "Member");
    }

    private async Task<(HttpClient Client, LoginResponse Login)> LoginAsAdminAsync()
    {
        return await LoginAsync(AdminEmail, "Admin");
    }

    private async Task<(HttpClient Client, LoginResponse Login)> LoginAsync(string email, string name)
    {
        var client = _factory.CreateClient();
        var register = await client.PostAsJsonAsync("/api/auth/register", new
        {
            name,
            email,
            password = Password
        });

        // Bootstrap admin email is reused across tests; 201 or 409 are both fine.
        Assert.True(
            register.StatusCode is HttpStatusCode.Created or HttpStatusCode.Conflict,
            $"Unexpected register status {register.StatusCode}: {await register.Content.ReadAsStringAsync()}");

        var login = await client.PostAsJsonAsync("/api/auth/login", new { email, password = Password });
        Assert.Equal(HttpStatusCode.OK, login.StatusCode);

        var payload = await login.Content.ReadFromJsonAsync<LoginResponse>(new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });
        Assert.NotNull(payload);
        Assert.False(string.IsNullOrWhiteSpace(payload!.Token));

        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", payload.Token);
        return (client, payload);
    }
}
