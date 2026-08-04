using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace ExpenseTracker.Api.Tests;

public class BudgetsEndpointsTests : IClassFixture<ApiWebApplicationFactory>
{
    private readonly ApiWebApplicationFactory _factory;

    public BudgetsEndpointsTests(ApiWebApplicationFactory factory)
    {
        _factory = factory;
    }

    private async Task<HttpClient> CreateAuthenticatedClientAsync()
    {
        var client = _factory.CreateClient();
        var email = $"budget_{Guid.NewGuid():N}@example.com";

        await client.PostAsJsonAsync("/api/auth/register", new
        {
            name = "User",
            email,
            password = "P@ssw0rd123"
        });

        var login = await client.PostAsJsonAsync("/api/auth/login", new
        {
            email,
            password = "P@ssw0rd123"
        });
        var payload = await login.Content.ReadFromJsonAsync<LoginResponse>();

        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", payload!.Token);
        return client;
    }

    [Fact]
    public async Task GetBudgets_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/api/budgets?year=2026&month=7");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task BudgetCrud_AndSpentTracking_Works()
    {
        var client = await CreateAuthenticatedClientAsync();
        const int year = 2026;
        const int month = 7;

        await client.PostAsJsonAsync("/api/expenses", new
        {
            title = "Lunch",
            amount = 100m,
            date = new DateTime(year, month, 5, 12, 0, 0, DateTimeKind.Utc),
            category = "Yemek",
            kind = "Expense"
        });
        await client.PostAsJsonAsync("/api/expenses", new
        {
            title = "Salary",
            amount = 5000m,
            date = new DateTime(year, month, 1, 12, 0, 0, DateTimeKind.Utc),
            category = "Maaş",
            kind = "Income"
        });

        var createOverall = await client.PostAsJsonAsync("/api/budgets", new
        {
            category = "",
            limitAmount = 500m,
            year,
            month
        });
        Assert.Equal(HttpStatusCode.Created, createOverall.StatusCode);
        var overall = await createOverall.Content.ReadFromJsonAsync<BudgetResponse>();
        Assert.NotNull(overall);
        Assert.Equal(100m, overall!.SpentAmount);
        Assert.Equal(400m, overall.RemainingAmount);
        Assert.False(overall.IsOverBudget);

        var createCategory = await client.PostAsJsonAsync("/api/budgets", new
        {
            category = "Yemek",
            limitAmount = 50m,
            year,
            month
        });
        Assert.Equal(HttpStatusCode.Created, createCategory.StatusCode);
        var categoryBudget = await createCategory.Content.ReadFromJsonAsync<BudgetResponse>();
        Assert.Equal(100m, categoryBudget!.SpentAmount);
        Assert.True(categoryBudget.IsOverBudget);

        var list = await client.GetFromJsonAsync<List<BudgetResponse>>(
            $"/api/budgets?year={year}&month={month}");
        Assert.NotNull(list);
        Assert.Equal(2, list!.Count);

        var duplicate = await client.PostAsJsonAsync("/api/budgets", new
        {
            category = "Yemek",
            limitAmount = 80m,
            year,
            month
        });
        Assert.Equal(HttpStatusCode.Conflict, duplicate.StatusCode);

        var update = await client.PutAsJsonAsync($"/api/budgets/{categoryBudget.Id}", new
        {
            category = "Yemek",
            limitAmount = 200m,
            year,
            month
        });
        Assert.Equal(HttpStatusCode.NoContent, update.StatusCode);

        var afterUpdate = await client.GetFromJsonAsync<BudgetResponse>(
            $"/api/budgets/{categoryBudget.Id}");
        Assert.Equal(200m, afterUpdate!.LimitAmount);
        Assert.False(afterUpdate.IsOverBudget);

        var delete = await client.DeleteAsync($"/api/budgets/{overall.Id}");
        Assert.Equal(HttpStatusCode.NoContent, delete.StatusCode);

        var listAfter = await client.GetFromJsonAsync<List<BudgetResponse>>(
            $"/api/budgets?year={year}&month={month}");
        Assert.Single(listAfter!);
    }
}
