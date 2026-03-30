using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Event;

public class CreateEventDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Description { get; set; }

    [Required]
    public DateTime Date { get; set; }

    public TimeSpan? Time { get; set; }

    [MaxLength(250)]
    public string? Location { get; set; }
}
