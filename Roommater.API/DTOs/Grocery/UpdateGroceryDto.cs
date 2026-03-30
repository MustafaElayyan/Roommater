using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Grocery;

public class UpdateGroceryDto
{
    [Range(1, 999)]
    public int Quantity { get; set; } = 1;

    public bool IsPurchased { get; set; }
}
