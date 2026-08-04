namespace ExpenseTracker.Api.DTOs;

public class BudgetResponseDto
{
    public Guid Id { get; set; }
    public string Category { get; set; } = string.Empty;
    public decimal LimitAmount { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }

    /// <summary>Sum of expense-kind transactions in the period (category-scoped when set).</summary>
    public decimal SpentAmount { get; set; }

    public decimal RemainingAmount => LimitAmount - SpentAmount;
    public bool IsOverBudget => SpentAmount > LimitAmount;
}
