using Roommater.API.DTOs.Listing;

namespace Roommater.API.Services;

public interface IListingService
{
    Task<List<ListingDto>> GetListingsAsync(Guid userId, int limit = 20, Guid? startAfterId = null);
    Task<ListingDto> GetByIdAsync(Guid id, Guid userId);
    Task<ListingDto> CreateAsync(Guid userId, CreateListingDto dto);
    Task DeleteAsync(Guid id, Guid userId);
}
