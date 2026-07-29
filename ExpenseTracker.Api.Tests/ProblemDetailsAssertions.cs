using System.Text.Json;
using Xunit;

namespace ExpenseTracker.Api.Tests;

internal static class ProblemDetailsAssertions
{
    public static async Task AssertProblemAsync(
        HttpResponseMessage response,
        int expectedStatus,
        string? detailContains = null)
    {
        Assert.Equal(expectedStatus, (int)response.StatusCode);

        var mediaType = response.Content.Headers.ContentType?.MediaType;
        Assert.NotNull(mediaType);
        Assert.Contains("json", mediaType, StringComparison.OrdinalIgnoreCase);

        var body = await response.Content.ReadAsStringAsync();
        Assert.False(string.IsNullOrWhiteSpace(body));

        Assert.DoesNotContain("at ExpenseTracker", body, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("StackTrace", body, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("NpgsqlException", body, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("SocketException", body, StringComparison.OrdinalIgnoreCase);

        using var doc = JsonDocument.Parse(body);
        var root = doc.RootElement;

        Assert.True(root.TryGetProperty("status", out var statusEl));
        Assert.Equal(expectedStatus, statusEl.GetInt32());

        Assert.True(root.TryGetProperty("title", out var titleEl));
        Assert.False(string.IsNullOrWhiteSpace(titleEl.GetString()));

        Assert.True(TryGetTraceId(root, out var traceId));
        Assert.False(string.IsNullOrWhiteSpace(traceId));

        if (detailContains is not null)
        {
            Assert.True(root.TryGetProperty("detail", out var detailEl));
            Assert.Contains(detailContains, detailEl.GetString() ?? string.Empty, StringComparison.OrdinalIgnoreCase);
        }
    }

    public static async Task AssertValidationProblemAsync(HttpResponseMessage response)
    {
        await AssertProblemAsync(response, expectedStatus: 400);
        var body = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(body);
        Assert.True(doc.RootElement.TryGetProperty("errors", out var errors));
        Assert.Equal(JsonValueKind.Object, errors.ValueKind);
        Assert.True(errors.EnumerateObject().Any());
    }

    private static bool TryGetTraceId(JsonElement root, out string? traceId)
    {
        if (root.TryGetProperty("traceId", out var direct))
        {
            traceId = direct.GetString();
            return true;
        }

        if (root.TryGetProperty("extensions", out var ext) &&
            ext.TryGetProperty("traceId", out var nested))
        {
            traceId = nested.GetString();
            return true;
        }

        traceId = null;
        return false;
    }
}
