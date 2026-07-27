using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class ExpenseUpdateDto
{
    [Required, StringLength(ValidationConstants.ExpenseTitleMaxLength)]
    public string Title { get; set; } = string.Empty;

    [Range(ValidationConstants.MinExpenseAmount, double.MaxValue)]
    public decimal Amount { get; set; }

    public DateTime Date { get; set; }

    [Required, StringLength(ValidationConstants.ExpenseCategoryMaxLength)]
    public string Category { get; set; } = string.Empty;
}
