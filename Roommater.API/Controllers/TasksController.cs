using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Task;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/households/{householdId:guid}/tasks")]
public class TasksController : ControllerBase
{
    private readonly ITaskService _service;

    public TasksController(ITaskService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get(Guid householdId, [FromQuery] bool myTasks = false, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetTasksAsync(householdId, userId, myTasks, page, pageSize);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid householdId, [FromBody] CreateTaskDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.CreateTaskAsync(householdId, userId, dto);
        return Ok(result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid householdId, Guid id, [FromBody] UpdateTaskDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.UpdateTaskAsync(householdId, id, userId, dto);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid householdId, Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.DeleteTaskAsync(householdId, id, userId);
        return NoContent();
    }
}
