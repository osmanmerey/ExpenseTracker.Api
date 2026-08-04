using System.Text.RegularExpressions;

namespace ExpenseTracker.Api.Common;

/// <summary>
/// Fixed FX rates matching the Flutter client (1 unit → TRY).
/// Currency is encoded in expense titles as <c>[USD] description</c>.
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

    public static decimal ToTry(decimal amount, string? title)
    {
        var code = ParseCurrencyCode(title);
        var rate = RatesToTry.GetValueOrDefault(code, 1m);
        return Math.Round(amount * rate, 2, MidpointRounding.AwayFromZero);
    }

    public static string ParseCurrencyCode(string? title)
    {
        if (string.IsNullOrWhiteSpace(title))
            return "TRY";

        var match = CurrencyTitlePattern().Match(title.Trim());
        if (!match.Success)
            return "TRY";

        var code = match.Groups[1].Value.ToUpperInvariant();
        return RatesToTry.ContainsKey(code) ? code : "TRY";
    }
}
