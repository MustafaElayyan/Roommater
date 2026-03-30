using Roommater.API.DTOs.Auth;

namespace Roommater.API.Services;

public interface IAuthService
{
    Task<AuthResponseDto> SignUpAsync(SignUpDto dto);
    Task<AuthResponseDto> SignInAsync(SignInDto dto);
    Task SignOutAsync(Guid userId);
    Task<DTOs.User.UserDto> GetMeAsync(Guid userId);
}
