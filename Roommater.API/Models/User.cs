using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required, EmailAddress, MaxLength(256)]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [Required, MaxLength(120)]
    public string DisplayName { get; set; } = string.Empty;

    [MaxLength(1024)]
    public string? PhotoUrl { get; set; }

    [MaxLength(1000)]
    public string? Bio { get; set; }

    public int? Age { get; set; }

    [MaxLength(120)]
    public string? Occupation { get; set; }

    [MaxLength(120)]
    public string? Location { get; set; }

    public Guid? HouseholdId { get; set; }
    public Household? Household { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<HouseholdTask> CreatedTasks { get; set; } = new List<HouseholdTask>();
    public ICollection<HouseholdTask> AssignedTasks { get; set; } = new List<HouseholdTask>();
    public ICollection<Event> CreatedEvents { get; set; } = new List<Event>();
    public ICollection<EventRsvp> EventRsvps { get; set; } = new List<EventRsvp>();
    public ICollection<GroceryItem> AddedGroceryItems { get; set; } = new List<GroceryItem>();
    public ICollection<Expense> PaidExpenses { get; set; } = new List<Expense>();
    public ICollection<ExpenseSplit> ExpenseSplits { get; set; } = new List<ExpenseSplit>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();
    public ICollection<ChatParticipant> ChatParticipants { get; set; } = new List<ChatParticipant>();
    public ICollection<Listing> Listings { get; set; } = new List<Listing>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}
