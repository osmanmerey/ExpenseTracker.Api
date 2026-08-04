namespace ExpenseTracker.Api.Models;

/// <summary>
/// Distinguishes money out (expense) from money in (income).
/// Stored as integer in the database; serialized as string in JSON.
/// </summary>
public enum TransactionKind
{
    Expense = 0,
    Income = 1
}
