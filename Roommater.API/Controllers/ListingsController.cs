using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Listing;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/listings")]
public class ListingsController : ControllerBase
{
    private readonly IListingService _service;

    public ListingsController(IListingService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] int limit = 20, [FromQuery] Guid? startAfterId = null)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetListingsAsync(userId, limit, startAfterId);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetByIdAsync(id, userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateListingDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.CreateAsync(userId, dto);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.DeleteAsync(id, userId);
        return NoContent();
    }
}
