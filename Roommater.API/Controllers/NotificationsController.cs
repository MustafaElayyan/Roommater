using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/notifications")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _service;

    public NotificationsController(INotificationService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetMyNotificationsAsync(userId, page, pageSize);
        return Ok(result);
    }

    [HttpPut("{id:guid}/read")]
    public async Task<IActionResult> MarkRead(Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.MarkReadAsync(id, userId);
        return NoContent();
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkReadAll()
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.MarkAllReadAsync(userId);
        return NoContent();
    }
}
