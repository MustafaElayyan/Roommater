namespace Roommater.API.DTOs.Grocery;

public class GroceryDto
{
    public Guid Id { get; set; }
    public Guid HouseholdId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public bool IsPurchased { get; set; }
    public Guid AddedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }
}
