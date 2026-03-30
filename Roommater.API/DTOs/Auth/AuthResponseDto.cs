using Roommater.API.DTOs.User;

namespace Roommater.API.DTOs.Auth;

public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
}
