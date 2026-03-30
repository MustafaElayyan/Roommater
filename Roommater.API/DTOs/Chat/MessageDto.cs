namespace Roommater.API.DTOs.Chat;

public class MessageDto
{
    public Guid Id { get; set; }
    public Guid ChatId { get; set; }
    public Guid SenderId { get; set; }
    public string Text { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
}
