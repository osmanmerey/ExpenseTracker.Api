using ExpenseTracker.Api.Models;

namespace ExpenseTracker.Api.DTOs;

public class ExpenseResponseDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Currency { get; set; } = "TRY";
    public TransactionKind Kind { get; set; }
}
