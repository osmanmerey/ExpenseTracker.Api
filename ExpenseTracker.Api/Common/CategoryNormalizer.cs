using System.Globalization;

namespace ExpenseTracker.Api.Common;

/// <summary>
/// Single rule for budget/expense category identity (trim + culture-invariant lower).
/// Display text stays as trimmed original; comparisons use <see cref="Key"/>.
/// </summary>
public static class CategoryNormalizer
{
    public static string Display(string? category) =>
        string.IsNullOrWhiteSpace(category) ? string.Empty : category.Trim();

    public static string Key(string? category) =>
        Display(category).ToLower(CultureInfo.InvariantCulture);
}
