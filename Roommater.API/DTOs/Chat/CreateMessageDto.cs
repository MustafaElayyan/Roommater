using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Chat;

public class CreateMessageDto
{
    [Required, MaxLength(4000)]
    public string Text { get; set; } = string.Empty;
}
