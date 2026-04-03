using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Grocery;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class GroceryService : IGroceryService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public GroceryService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<GroceryDto>> GetItemsAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var items = await _db.GroceryItems
            .Where(g => g.HouseholdId == householdId)
            .OrderBy(g => g.IsPurchased)
            .ThenBy(g => g.CreatedAt)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return items.Select(_mapper.Map<GroceryDto>).ToList();
    }

    public async Task<GroceryDto> AddItemAsync(Guid householdId, Guid userId, CreateGroceryDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var item = new GroceryItem
        {
            HouseholdId = householdId,
            Name = dto.Name.Trim(),
            Quantity = dto.Quantity,
            AddedByUserId = userId
        };

        _db.GroceryItems.Add(item);
        await _db.SaveChangesAsync();

        return _mapper.Map<GroceryDto>(item);
    }

    public async Task<GroceryDto> UpdateItemAsync(Guid householdId, Guid itemId, Guid userId, UpdateGroceryDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var item = await _db.GroceryItems.FirstOrDefaultAsync(g => g.Id == itemId && g.HouseholdId == householdId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "Grocery item not found.");

        item.Quantity = dto.Quantity;
        item.IsPurchased = dto.IsPurchased;
        if (!string.IsNullOrWhiteSpace(dto.Name))
        {
            item.Name = dto.Name.Trim();
        }

        await _db.SaveChangesAsync();

        return _mapper.Map<GroceryDto>(item);
    }

    public async Task DeleteItemAsync(Guid householdId, Guid itemId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var item = await _db.GroceryItems.FirstOrDefaultAsync(g => g.Id == itemId && g.HouseholdId == householdId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "Grocery item not found.");

        _db.GroceryItems.Remove(item);
        await _db.SaveChangesAsync();
    }
}
