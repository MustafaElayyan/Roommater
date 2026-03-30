using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Listing;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class ListingService : IListingService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public ListingService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<ListingDto>> GetListingsAsync(Guid userId, int limit = 20, Guid? startAfterId = null)
    {
        var cappedLimit = Math.Clamp(limit, 1, 100);
        var query = _db.Listings.Where(l => l.IsAvailable);

        if (startAfterId.HasValue)
        {
            var startAfter = await _db.Listings.AsNoTracking().FirstOrDefaultAsync(l => l.Id == startAfterId.Value);
            if (startAfter is not null)
            {
                query = query.Where(l => l.PostedAt < startAfter.PostedAt || (l.PostedAt == startAfter.PostedAt && l.Id.CompareTo(startAfter.Id) > 0));
            }
        }

        var listings = await query
            .OrderByDescending(l => l.PostedAt)
            .ThenBy(l => l.Id)
            .Take(cappedLimit)
            .ToListAsync();

        return listings.Select(_mapper.Map<ListingDto>).ToList();
    }

    public async Task<ListingDto> GetByIdAsync(Guid id, Guid userId)
    {
        var listing = await _db.Listings.FirstOrDefaultAsync(l => l.Id == id)
                      ?? throw new ApiException(HttpStatusCode.NotFound, "Listing not found.");

        return _mapper.Map<ListingDto>(listing);
    }

    public async Task<ListingDto> CreateAsync(Guid userId, CreateListingDto dto)
    {
        var listing = new Listing
        {
            OwnerId = userId,
            Title = dto.Title.Trim(),
            Description = dto.Description?.Trim(),
            Rent = dto.Rent,
            Location = dto.Location?.Trim(),
            ImageUrls = dto.ImageUrls,
            IsAvailable = true,
            PostedAt = DateTime.UtcNow
        };

        _db.Listings.Add(listing);
        await _db.SaveChangesAsync();

        return _mapper.Map<ListingDto>(listing);
    }

    public async Task DeleteAsync(Guid id, Guid userId)
    {
        var listing = await _db.Listings.FirstOrDefaultAsync(l => l.Id == id)
                      ?? throw new ApiException(HttpStatusCode.NotFound, "Listing not found.");

        if (listing.OwnerId != userId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only listing owner can delete listing.");
        }

        _db.Listings.Remove(listing);
        await _db.SaveChangesAsync();
    }
}
