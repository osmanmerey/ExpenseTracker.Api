using System.ComponentModel.DataAnnotations;

namespace ExpenseTracker.Api.DTOs;

public class ExpenseUpdateDto
{
    [Required, StringLength(200)]
    public string Title { get; set; } = string.Empty;

    [Range(0.01, double.MaxValue)]
    public decimal Amount { get; set; }

    public DateTime Date { get; set; }

    [Required, StringLength(100)]
    public string Category { get; set; } = string.Empty;
}
