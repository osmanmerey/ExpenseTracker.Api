using System.ComponentModel.DataAnnotations;

namespace ExpenseTracker.Api.DTOs;

public class UserUpdateDto
{
    [Required, StringLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required, EmailAddress, StringLength(254)]
    public string Email { get; set; } = string.Empty;
}
