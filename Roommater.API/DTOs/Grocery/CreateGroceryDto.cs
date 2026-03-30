using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Grocery;

public class CreateGroceryDto
{
    [Required, MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [Range(1, 999)]
    public int Quantity { get; set; } = 1;
}
