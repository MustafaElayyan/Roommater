namespace Roommater.API.DTOs.Listing;

public class ListingDto
{
    public Guid Id { get; set; }
    public Guid OwnerId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Rent { get; set; }
    public string? Location { get; set; }
    public List<string> ImageUrls { get; set; } = new();
    public DateTime PostedAt { get; set; }
    public bool IsAvailable { get; set; }
}
