namespace ExpenseTracker.Api.Tests;

// Lightweight response shapes for deserializing API results in tests.
public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public UserSummary User { get; set; } = new();
}

public class UserSummary
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = "user";
}

public class ExpenseResponse
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Currency { get; set; } = "TRY";
    public string Kind { get; set; } = "Expense";
}

public class BudgetResponse
{
    public Guid Id { get; set; }
    public string Category { get; set; } = string.Empty;
    public decimal LimitAmount { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal SpentAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public bool IsOverBudget { get; set; }
}

public class ForgotPasswordResponse
{
    public string Message { get; set; } = string.Empty;
    public string? ResetToken { get; set; }
}
