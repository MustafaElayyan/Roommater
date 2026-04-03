using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Grocery;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/households/{householdId:guid}/grocery")]
public class GroceryController : ControllerBase
{
    private readonly IGroceryService _service;

    public GroceryController(IGroceryService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get(Guid householdId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetItemsAsync(householdId, userId, page, pageSize);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid householdId, [FromBody] CreateGroceryDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.AddItemAsync(householdId, userId, dto);
        return Ok(result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid householdId, Guid id, [FromBody] UpdateGroceryDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.UpdateItemAsync(householdId, id, userId, dto);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid householdId, Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.DeleteItemAsync(householdId, id, userId);
        return NoContent();
    }
}
