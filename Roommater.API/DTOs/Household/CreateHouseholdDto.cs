using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Household;

public class CreateHouseholdDto
{
    [Required, MaxLength(120)]
    public string Name { get; set; } = string.Empty;
}
