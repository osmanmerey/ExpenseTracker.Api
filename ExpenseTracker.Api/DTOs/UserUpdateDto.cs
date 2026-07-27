using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class UserUpdateDto
{
    [Required, StringLength(ValidationConstants.NameMaxLength)]
    public string Name { get; set; } = string.Empty;

    [Required, EmailAddress, StringLength(ValidationConstants.EmailMaxLength)]
    public string Email { get; set; } = string.Empty;
}
