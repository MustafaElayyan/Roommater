using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Household;

public class JoinHouseholdDto
{
    [Required, Length(6, 6)]
    public string InviteCode { get; set; } = string.Empty;
}
