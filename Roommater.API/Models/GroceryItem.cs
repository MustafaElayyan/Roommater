using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class GroceryItem
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid HouseholdId { get; set; }
    public Household? Household { get; set; }

    [Required, MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    public int Quantity { get; set; } = 1;

    public bool IsPurchased { get; set; }

    public Guid AddedByUserId { get; set; }
    public User? AddedByUser { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
