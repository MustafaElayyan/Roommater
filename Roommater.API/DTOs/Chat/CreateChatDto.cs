using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Chat;

public class CreateChatDto
{
    [Required]
    public List<Guid> ParticipantIds { get; set; } = new();
}
