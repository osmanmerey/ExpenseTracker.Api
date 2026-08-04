namespace ExpenseTracker.Api.Models;

/// <summary>
/// Monthly spending limit for a user. Empty <see cref="Category"/> means overall budget.
/// </summary>
public class Budget
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    /// <summary>Empty = all expense categories for the month.</summary>
    public string Category { get; set; } = string.Empty;

    public decimal LimitAmount { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
}
