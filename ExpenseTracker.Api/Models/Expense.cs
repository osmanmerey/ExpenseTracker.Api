namespace ExpenseTracker.Api.Models;

public class Expense
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string Category { get; set; } = string.Empty;
    public TransactionKind Kind { get; set; } = TransactionKind.Expense;

    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
}