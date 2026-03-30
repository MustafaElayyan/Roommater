namespace Roommater.API.DTOs.User;

public class UserDto
{
    public Guid Uid { get; set; }
    public string Email { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public string? Bio { get; set; }
    public int? Age { get; set; }
    public string? Occupation { get; set; }
    public string? Location { get; set; }
}
