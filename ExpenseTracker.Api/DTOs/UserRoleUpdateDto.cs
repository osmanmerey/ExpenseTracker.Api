using System.ComponentModel.DataAnnotations;
using ExpenseTracker.Api.Common;

namespace ExpenseTracker.Api.DTOs;

public class UserRoleUpdateDto
{
    [Required, StringLength(UserRoles.MaxLength)]
    public string Role { get; set; } = string.Empty;
}
