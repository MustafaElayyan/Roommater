using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Expense;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/households/{householdId:guid}/expenses")]
public class ExpensesController : ControllerBase
{
    private readonly IExpenseService _service;

    public ExpensesController(IExpenseService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get(Guid householdId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetExpensesAsync(householdId, userId, page, pageSize);
        return Ok(result);
    }

    [HttpGet("balances")]
    public async Task<IActionResult> Balances(Guid householdId)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.GetBalancesAsync(householdId, userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(Guid householdId, [FromBody] CreateExpenseDto dto)
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _service.CreateExpenseAsync(householdId, userId, dto);
        return Ok(result);
    }

    [HttpPut("{id:guid}/splits/{splitId:guid}/pay")]
    public async Task<IActionResult> MarkPaid(Guid householdId, Guid id, Guid splitId)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.MarkSplitPaidAsync(householdId, id, splitId, userId);
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid householdId, Guid id)
    {
        var userId = CurrentUser.GetUserId(User);
        await _service.DeleteExpenseAsync(householdId, id, userId);
        return NoContent();
    }
}
