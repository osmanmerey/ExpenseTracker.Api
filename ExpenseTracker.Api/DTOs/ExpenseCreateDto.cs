using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.DTOs;

public class ExpenseCreateDto
{
    [Required, StringLength(ValidationConstants.ExpenseTitleMaxLength)]
    public string Title { get; set; } = string.Empty;

    [Range(ValidationConstants.MinExpenseAmount, double.MaxValue)]
    public decimal Amount { get; set; }

    public DateTime Date { get; set; }

    [Required, StringLength(ValidationConstants.ExpenseCategoryMaxLength)]
    public string Category { get; set; } = string.Empty;

    /// <summary>ISO 4217; defaults to TRY. Unknown/omitted codes map to TRY (or title prefix).</summary>
    [StringLength(ValidationConstants.CurrencyCodeLength)]
    public string? Currency { get; set; }

    /// <summary>Defaults to Expense when omitted.</summary>
    public TransactionKind Kind { get; set; } = TransactionKind.Expense;
}
