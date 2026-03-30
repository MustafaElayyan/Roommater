using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class Message
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ChatId { get; set; }
    public Chat? Chat { get; set; }

    public Guid SenderId { get; set; }
    public User? Sender { get; set; }

    [Required, MaxLength(4000)]
    public string Text { get; set; } = string.Empty;

    public DateTime SentAt { get; set; } = DateTime.UtcNow;
}
