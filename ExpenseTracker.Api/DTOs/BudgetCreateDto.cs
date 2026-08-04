using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class BudgetCreateDto
{
    /// <summary>Empty or whitespace = overall monthly budget.</summary>
    [StringLength(ValidationConstants.BudgetCategoryMaxLength)]
    public string Category { get; set; } = string.Empty;

    [Range(ValidationConstants.MinBudgetAmount, double.MaxValue)]
    public decimal LimitAmount { get; set; }

    [Range(ValidationConstants.MinBudgetYear, ValidationConstants.MaxBudgetYear)]
    public int Year { get; set; }

    [Range(ValidationConstants.MinBudgetMonth, ValidationConstants.MaxBudgetMonth)]
    public int Month { get; set; }
}
