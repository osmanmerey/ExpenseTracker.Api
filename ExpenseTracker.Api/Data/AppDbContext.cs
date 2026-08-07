using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ExpenseTracker.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Expense> Expenses { get; set; }
    public DbSet<Budget> Budgets { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Expense>()
            .HasOne(e => e.User)
            .WithMany(u => u.Expenses)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Expense>()
            .Property(e => e.Kind)
            .HasDefaultValue(TransactionKind.Expense);

        modelBuilder.Entity<Expense>()
            .Property(e => e.Currency)
            .HasMaxLength(ValidationConstants.CurrencyCodeLength)
            .HasDefaultValue("TRY");

        modelBuilder.Entity<Budget>()
            .HasOne(b => b.User)
            .WithMany(u => u.Budgets)
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Budget>()
            .HasIndex(b => new { b.UserId, b.Year, b.Month, b.Category })
            .IsUnique();
    }
}
