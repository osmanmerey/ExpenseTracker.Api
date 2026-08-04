using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class ResetPasswordDto
{
    [Required, EmailAddress, StringLength(ValidationConstants.EmailMaxLength)]
    public string Email { get; set; } = string.Empty;

    [Required, StringLength(200, MinimumLength = 8)]
    public string Token { get; set; } = string.Empty;

    [Required, MinLength(ValidationConstants.PasswordMinLength), MaxLength(ValidationConstants.PasswordMaxLength)]
    public string NewPassword { get; set; } = string.Empty;
}
