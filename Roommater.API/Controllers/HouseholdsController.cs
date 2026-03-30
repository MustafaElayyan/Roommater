using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Household;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/households")]
public class HouseholdsController : ControllerBase
{
    private readonly IHouseholdService _service;

    public HouseholdsController(IHouseholdService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateHouseholdDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.CreateAsync(userId, dto);
        return Ok(result);
    }

    [HttpPost("join")]
    public async Task<IActionResult> Join([FromBody] JoinHouseholdDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.JoinAsync(userId, dto);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetByIdAsync(id, userId);
        return Ok(result);
    }

    [HttpGet("{id:guid}/members")]
    public async Task<IActionResult> Members(Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetMembersAsync(id, userId);
        return Ok(result);
    }

    [HttpDelete("{id:guid}/members/{userId:guid}")]
    public async Task<IActionResult> RemoveMember(Guid id, Guid userId)
    {
        var actor = CurrentUser.GetUserId(User);
        await _service.RemoveMemberAsync(id, actor, userId);
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var actor = CurrentUser.GetUserId(User);
        await _service.DeleteAsync(id, actor);
        return NoContent();
    }
}
