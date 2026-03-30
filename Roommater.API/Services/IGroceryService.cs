using Roommater.API.DTOs.Grocery;

namespace Roommater.API.Services;

public interface IGroceryService
{
    Task<List<GroceryDto>> GetItemsAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50);
    Task<GroceryDto> AddItemAsync(Guid householdId, Guid userId, CreateGroceryDto dto);
    Task<GroceryDto> UpdateItemAsync(Guid householdId, Guid itemId, Guid userId, UpdateGroceryDto dto);
    Task DeleteItemAsync(Guid householdId, Guid itemId, Guid userId);
}
