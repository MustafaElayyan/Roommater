using Roommater.API.DTOs.User;

namespace Roommater.API.Services;

public interface IUserService
{
    Task<UserDto> GetByIdAsync(Guid id);
    Task<UserDto> UpdateProfileAsync(Guid id, Guid currentUserId, UpdateProfileDto dto);
}
