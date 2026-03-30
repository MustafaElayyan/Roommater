namespace Roommater.API.DTOs.Event;

public class EventDto
{
    public Guid Id { get; set; }
    public Guid HouseholdId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime Date { get; set; }
    public TimeSpan? Time { get; set; }
    public string? Location { get; set; }
    public Guid CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public int YesCount { get; set; }
    public int MaybeCount { get; set; }
    public int NoCount { get; set; }
}
