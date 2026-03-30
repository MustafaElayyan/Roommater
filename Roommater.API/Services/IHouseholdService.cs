using Roommater.API.DTOs.Household;
using Roommater.API.DTOs.User;

namespace Roommater.API.Services;

public interface IHouseholdService
{
    Task<HouseholdDto> CreateAsync(Guid userId, CreateHouseholdDto dto);
    Task<HouseholdDto> JoinAsync(Guid userId, JoinHouseholdDto dto);
    Task<HouseholdDto> GetByIdAsync(Guid householdId, Guid userId);
    Task<List<UserDto>> GetMembersAsync(Guid householdId, Guid userId);
    Task RemoveMemberAsync(Guid householdId, Guid actorUserId, Guid memberUserId);
    Task DeleteAsync(Guid householdId, Guid actorUserId);
}
