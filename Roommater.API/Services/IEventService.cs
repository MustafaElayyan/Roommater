using Roommater.API.DTOs.Event;

namespace Roommater.API.Services;

public interface IEventService
{
    Task<List<EventDto>> GetEventsAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50);
    Task<EventDto> GetEventAsync(Guid householdId, Guid eventId, Guid userId);
    Task<EventDto> CreateEventAsync(Guid householdId, Guid userId, CreateEventDto dto);
    Task RsvpAsync(Guid householdId, Guid eventId, Guid userId, RsvpDto dto);
    Task DeleteEventAsync(Guid householdId, Guid eventId, Guid userId);
}
