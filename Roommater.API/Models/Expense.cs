using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class Expense
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid HouseholdId { get; set; }
    public Household? Household { get; set; }

    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public decimal Amount { get; set; }

    [Required, MaxLength(10)]
    public string Currency { get; set; } = "JOD";

    [Required, MaxLength(80)]
    public string Category { get; set; } = "Household";

    public Guid PaidByUserId { get; set; }
    public User? PaidByUser { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<ExpenseSplit> Splits { get; set; } = new List<ExpenseSplit>();
}
