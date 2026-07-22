using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace ExpenseTracker.Api.Tests;

public class ExpensesEndpointsTests : IClassFixture<ApiWebApplicationFactory>
{
    private readonly ApiWebApplicationFactory _factory;

    public ExpensesEndpointsTests(ApiWebApplicationFactory factory)
    {
        _factory = factory;
    }

    private async Task<HttpClient> CreateAuthenticatedClientAsync(string? email = null)
    {
        var client = _factory.CreateClient();
        email ??= $"user_{Guid.NewGuid():N}@example.com";

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

    private static object SampleExpense(string title = "Groceries") => new
    {
        title,
        amount = 42.50m,
        date = DateTime.UtcNow,
        category = "Food"
    };

    [Fact]
    public async Task GetExpenses_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/api/expenses");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task PostExpense_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/expenses", SampleExpense());

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task CreateExpense_WithInvalidInput_ReturnsBadRequest()
    {
        var client = await CreateAuthenticatedClientAsync();

        var response = await client.PostAsJsonAsync("/api/expenses", new
        {
            title = "",
            amount = 0,
            date = DateTime.UtcNow,
            category = ""
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task ExpenseCrud_FullFlow_Works()
    {
        var client = await CreateAuthenticatedClientAsync();

        // Create
        var createResponse = await client.PostAsJsonAsync("/api/expenses", SampleExpense());
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<ExpenseResponse>();
        Assert.NotNull(created);
        Assert.NotEqual(Guid.Empty, created!.Id);

        // List
        var list = await client.GetFromJsonAsync<List<ExpenseResponse>>("/api/expenses");
        Assert.NotNull(list);
        Assert.Contains(list!, e => e.Id == created.Id);

        // Get by id
        var single = await client.GetFromJsonAsync<ExpenseResponse>($"/api/expenses/{created.Id}");
        Assert.NotNull(single);
        Assert.Equal("Groceries", single!.Title);

        // Update
        var updateResponse = await client.PutAsJsonAsync($"/api/expenses/{created.Id}", new
        {
            title = "Groceries Updated",
            amount = 99.99m,
            date = DateTime.UtcNow,
            category = "Household"
        });
        Assert.Equal(HttpStatusCode.NoContent, updateResponse.StatusCode);

        var afterUpdate = await client.GetFromJsonAsync<ExpenseResponse>($"/api/expenses/{created.Id}");
        Assert.Equal("Groceries Updated", afterUpdate!.Title);
        Assert.Equal(99.99m, afterUpdate.Amount);

        // Delete
        var deleteResponse = await client.DeleteAsync($"/api/expenses/{created.Id}");
        Assert.Equal(HttpStatusCode.NoContent, deleteResponse.StatusCode);

        var afterDelete = await client.GetAsync($"/api/expenses/{created.Id}");
        Assert.Equal(HttpStatusCode.NotFound, afterDelete.StatusCode);
    }

    [Fact]
    public async Task UserCannotAccessAnotherUsersExpense()
    {
        // User A creates an expense
        var clientA = await CreateAuthenticatedClientAsync();
        var createResponse = await clientA.PostAsJsonAsync("/api/expenses", SampleExpense("A private expense"));
        var createdByA = await createResponse.Content.ReadFromJsonAsync<ExpenseResponse>();

        // User B is a different account
        var clientB = await CreateAuthenticatedClientAsync();

        // B cannot see A's expense in the list
        var listForB = await clientB.GetFromJsonAsync<List<ExpenseResponse>>("/api/expenses");
        Assert.DoesNotContain(listForB!, e => e.Id == createdByA!.Id);

        // B cannot read A's expense by id
        var getByB = await clientB.GetAsync($"/api/expenses/{createdByA!.Id}");
        Assert.Equal(HttpStatusCode.NotFound, getByB.StatusCode);

        // B cannot update A's expense
        var updateByB = await clientB.PutAsJsonAsync($"/api/expenses/{createdByA.Id}", new
        {
            title = "Hacked",
            amount = 1m,
            date = DateTime.UtcNow,
            category = "x"
        });
        Assert.Equal(HttpStatusCode.NotFound, updateByB.StatusCode);

        // B cannot delete A's expense
        var deleteByB = await clientB.DeleteAsync($"/api/expenses/{createdByA.Id}");
        Assert.Equal(HttpStatusCode.NotFound, deleteByB.StatusCode);

        // A can still access it (unchanged)
        var stillThere = await clientA.GetFromJsonAsync<ExpenseResponse>($"/api/expenses/{createdByA.Id}");
        Assert.Equal("A private expense", stillThere!.Title);
    }
}
