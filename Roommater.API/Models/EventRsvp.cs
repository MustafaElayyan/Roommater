namespace Roommater.API.Models;

public enum EventRsvpStatus
{
    Yes = 1,
    Maybe = 2,
    No = 3
}

public class EventRsvp
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid EventId { get; set; }
    public Event? Event { get; set; }

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public EventRsvpStatus Status { get; set; }
}
