using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class Event
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid HouseholdId { get; set; }
    public Household? Household { get; set; }

    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Description { get; set; }

    public DateTime Date { get; set; }

    public TimeSpan? Time { get; set; }

    [MaxLength(250)]
    public string? Location { get; set; }

    public Guid CreatedByUserId { get; set; }
    public User? CreatedByUser { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<EventRsvp> Rsvps { get; set; } = new List<EventRsvp>();
}
