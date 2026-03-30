using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Event;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class EventService : IEventService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public EventService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<EventDto>> GetEventsAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var events = await _db.Events
            .Include(e => e.Rsvps)
            .Where(e => e.HouseholdId == householdId)
            .OrderBy(e => e.Date)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return events.Select(ToEventDto).ToList();
    }

    public async Task<EventDto> GetEventAsync(Guid householdId, Guid eventId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var @event = await _db.Events
            .Include(e => e.Rsvps)
            .FirstOrDefaultAsync(e => e.Id == eventId && e.HouseholdId == householdId)
            ?? throw new ApiException(HttpStatusCode.NotFound, "Event not found.");

        return ToEventDto(@event);
    }

    public async Task<EventDto> CreateEventAsync(Guid householdId, Guid userId, CreateEventDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var @event = new Event
        {
            HouseholdId = householdId,
            Title = dto.Title.Trim(),
            Description = dto.Description?.Trim(),
            Date = dto.Date,
            Time = dto.Time,
            Location = dto.Location?.Trim(),
            CreatedByUserId = userId
        };

        _db.Events.Add(@event);
        await _db.SaveChangesAsync();

        return ToEventDto(@event);
    }

    public async Task RsvpAsync(Guid householdId, Guid eventId, Guid userId, RsvpDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var @event = await _db.Events.AnyAsync(e => e.Id == eventId && e.HouseholdId == householdId);
        if (!@event)
        {
            throw new ApiException(HttpStatusCode.NotFound, "Event not found.");
        }

        var existing = await _db.EventRsvps.FirstOrDefaultAsync(r => r.EventId == eventId && r.UserId == userId);
        if (existing is null)
        {
            _db.EventRsvps.Add(new EventRsvp
            {
                EventId = eventId,
                UserId = userId,
                Status = dto.Status
            });
        }
        else
        {
            existing.Status = dto.Status;
        }

        await _db.SaveChangesAsync();
    }

    public async Task DeleteEventAsync(Guid householdId, Guid eventId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var @event = await _db.Events.FirstOrDefaultAsync(e => e.Id == eventId && e.HouseholdId == householdId)
            ?? throw new ApiException(HttpStatusCode.NotFound, "Event not found.");

        if (@event.CreatedByUserId != userId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only event creator can delete this event.");
        }

        _db.Events.Remove(@event);
        await _db.SaveChangesAsync();
    }

    private EventDto ToEventDto(Event @event)
    {
        var dto = _mapper.Map<EventDto>(@event);
        dto.YesCount = @event.Rsvps.Count(r => r.Status == EventRsvpStatus.Yes);
        dto.MaybeCount = @event.Rsvps.Count(r => r.Status == EventRsvpStatus.Maybe);
        dto.NoCount = @event.Rsvps.Count(r => r.Status == EventRsvpStatus.No);
        return dto;
    }
}
