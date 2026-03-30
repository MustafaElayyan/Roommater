using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Event;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/households/{householdId:guid}/events")]
public class EventsController : ControllerBase
{
    private readonly IEventService _service;

    public EventsController(IEventService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get(Guid householdId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetEventsAsync(householdId, userId, page, pageSize);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid householdId, Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetEventAsync(householdId, id, userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid householdId, [FromBody] CreateEventDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.CreateEventAsync(householdId, userId, dto);
        return Ok(result);
    }

    [HttpPost("{id:guid}/rsvp")]
    public async Task<IActionResult> Rsvp(Guid householdId, Guid id, [FromBody] RsvpDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.RsvpAsync(householdId, id, userId, dto);
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid householdId, Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.DeleteEventAsync(householdId, id, userId);
        return NoContent();
    }
}
