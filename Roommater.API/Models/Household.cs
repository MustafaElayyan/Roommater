using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class Household
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required, MaxLength(120)]
    public string Name { get; set; } = string.Empty;

    [Required, MaxLength(6)]
    public string InviteCode { get; set; } = string.Empty;

    public Guid CreatedByUserId { get; set; }
    public User? CreatedByUser { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<User> Members { get; set; } = new List<User>();
    public ICollection<HouseholdTask> Tasks { get; set; } = new List<HouseholdTask>();
    public ICollection<Event> Events { get; set; } = new List<Event>();
    public ICollection<GroceryItem> GroceryItems { get; set; } = new List<GroceryItem>();
    public ICollection<Expense> Expenses { get; set; } = new List<Expense>();
}
