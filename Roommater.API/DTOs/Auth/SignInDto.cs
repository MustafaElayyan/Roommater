using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Auth;

public class SignInDto
{
    [Required, EmailAddress, MaxLength(256)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(8), MaxLength(100)]
    public string Password { get; set; } = string.Empty;
}
