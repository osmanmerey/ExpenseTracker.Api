namespace ExpenseTracker.Api.Common;

/// <summary>
/// Field-length / range limits used by DataAnnotation attributes on DTOs.
/// Kept as named constants instead of repeated magic numbers (e.g. 100, 254, 200).
/// </summary>
public static class ValidationConstants
{
    public const int NameMaxLength = 100;
    public const int EmailMaxLength = 254;

    public const int PasswordMinLength = 8;
    public const int PasswordMaxLength = 100;

    public const int ExpenseTitleMaxLength = 200;
    public const int ExpenseCategoryMaxLength = 100;

    public const double MinExpenseAmount = 0.01;

    public const int BudgetCategoryMaxLength = 100;
    public const double MinBudgetAmount = 0.01;
    public const int MinBudgetMonth = 1;
    public const int MaxBudgetMonth = 12;
    public const int MinBudgetYear = 2000;
    public const int MaxBudgetYear = 2100;
}
