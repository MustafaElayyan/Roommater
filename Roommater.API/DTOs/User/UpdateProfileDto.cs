using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.User;

public class UpdateProfileDto
{
    [Required, MaxLength(120)]
    public string DisplayName { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Bio { get; set; }

    [MaxLength(1024)]
    public string? PhotoUrl { get; set; }

    [Range(0, 120)]
    public int? Age { get; set; }

    [MaxLength(120)]
    public string? Occupation { get; set; }

    [MaxLength(120)]
    public string? Location { get; set; }
}
