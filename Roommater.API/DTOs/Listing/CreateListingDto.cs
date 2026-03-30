using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Listing;

public class CreateListingDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(4000)]
    public string? Description { get; set; }

    [Range(0.01, 1000000)]
    public decimal Rent { get; set; }

    [MaxLength(250)]
    public string? Location { get; set; }

    public List<string> ImageUrls { get; set; } = new();
}
