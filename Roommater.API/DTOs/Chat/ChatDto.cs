namespace Roommater.API.DTOs.Chat;

public class ChatDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<Guid> ParticipantIds { get; set; } = new();
}
