using Roommater.API.DTOs.User;

namespace Roommater.API.DTOs.Household;

public class HouseholdDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string InviteCode { get; set; } = string.Empty;
    public Guid CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<UserDto> Members { get; set; } = new();
}
