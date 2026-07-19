namespace ExpenseTracker.Api.Models;

public class User
{
    // int yerine Guid kullanıyoruz ve yeni bir Guid oluşturuyoruz
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;

    public ICollection<Expense>? Expenses { get; set; }
}