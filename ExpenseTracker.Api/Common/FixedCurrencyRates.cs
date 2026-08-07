using System.Text.RegularExpressions;

namespace ExpenseTracker.Api.Common;

/// <summary>
/// Fixed FX rates matching Flutter <c>lib/core/currency/fixed_exchange_rates.dart</c>
/// (USD=47, EUR=54, GBP=63). Prefer <c>Expense.Currency</c>; title prefix is legacy.
/// Also exposed via GET /api/currencies.
/// </summary>
public static partial class FixedCurrencyRates
{
    private static readonly Dictionary<string, decimal> RatesToTry = new(StringComparer.OrdinalIgnoreCase)
    {
        ["TRY"] = 1m,
        ["USD"] = 47m,
        ["EUR"] = 54m,
        ["GBP"] = 63m
    };

    [GeneratedRegex(@"^\[([A-Za-z]{3})\]\s*(.*)$", RegexOptions.CultureInvariant)]
    private static partial Regex CurrencyTitlePattern();

    public static IReadOnlyDictionary<string, decimal> AllRates => RatesToTry;

    public static bool IsKnown(string? code) =>
        !string.IsNullOrWhiteSpace(code) && RatesToTry.ContainsKey(code.Trim());

    public static string Normalize(string? code)
    {
        if (string.IsNullOrWhiteSpace(code))
            return "TRY";
        var normalized = code.Trim().ToUpperInvariant();
        return RatesToTry.ContainsKey(normalized) ? normalized : "TRY";
    }

    public static decimal ToTry(decimal amount, string? currencyCode, string? titleFallback = null)
    {
        var code = !string.IsNullOrWhiteSpace(currencyCode)
            ? Normalize(currencyCode)
            : ParseCurrencyCodeFromTitle(titleFallback);

        var rate = RatesToTry.GetValueOrDefault(code, 1m);
        return Math.Round(amount * rate, 2, MidpointRounding.AwayFromZero);
    }

    /// <summary>Legacy: currency encoded as <c>[USD] description</c> in title.</summary>
    public static string ParseCurrencyCodeFromTitle(string? title)
    {
        if (string.IsNullOrWhiteSpace(title))
            return "TRY";

        var match = CurrencyTitlePattern().Match(title.Trim());
        if (!match.Success)
            return "TRY";

        var code = match.Groups[1].Value.ToUpperInvariant();
        return RatesToTry.ContainsKey(code) ? code : "TRY";
    }

    public static string StripCurrencyPrefix(string? title)
    {
        if (string.IsNullOrWhiteSpace(title))
            return string.Empty;
        var match = CurrencyTitlePattern().Match(title.Trim());
        return match.Success ? (match.Groups[2].Value ?? string.Empty).Trim() : title.Trim();
    }
}
