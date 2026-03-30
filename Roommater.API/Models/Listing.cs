using System.ComponentModel.DataAnnotations;

namespace Roommater.API.Models;

public class Listing
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid OwnerId { get; set; }
    public User? Owner { get; set; }

    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(4000)]
    public string? Description { get; set; }

    public decimal Rent { get; set; }

    [MaxLength(250)]
    public string? Location { get; set; }

    public List<string> ImageUrls { get; set; } = new();

    public bool IsAvailable { get; set; } = true;

    public DateTime PostedAt { get; set; } = DateTime.UtcNow;
}
