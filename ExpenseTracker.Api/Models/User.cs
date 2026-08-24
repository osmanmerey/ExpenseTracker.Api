using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.Models;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;

    public string Role { get; set; } = UserRoles.User;

    public ICollection<Expense>? Expenses { get; set; }
    public ICollection<Budget>? Budgets { get; set; }
}
