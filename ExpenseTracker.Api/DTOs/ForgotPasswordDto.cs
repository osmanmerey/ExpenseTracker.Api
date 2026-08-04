using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class ForgotPasswordDto
{
    [Required, EmailAddress, StringLength(ValidationConstants.EmailMaxLength)]
    public string Email { get; set; } = string.Empty;
}
