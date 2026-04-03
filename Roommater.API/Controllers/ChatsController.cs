using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Chat;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/chats")]
public class ChatsController : ControllerBase
{
    private readonly IChatService _service;

    public ChatsController(IChatService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] Guid? userId = null, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var currentUser = CurrentUser.GetUserId(User);
        var result = await _service.GetChatsAsync(currentUser, userId, page, pageSize);
        return Ok(result);
    }

    [HttpGet("{chatId:guid}/messages")]
    public async Task<IActionResult> Messages(Guid chatId, [FromQuery] int page = 1, [FromQuery] int pageSize = 100)
    {
        var currentUser = CurrentUser.GetUserId(User);
        var result = await _service.GetMessagesAsync(chatId, currentUser, page, pageSize);
        return Ok(result);
    }

    [HttpPost("{chatId:guid}/messages")]
    public async Task<IActionResult> Send(Guid chatId, [FromBody] CreateMessageDto dto)
    {
        var currentUser = CurrentUser.GetUserId(User);
        var result = await _service.SendMessageAsync(chatId, currentUser, dto);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateChatDto dto)
    {
        var currentUser = CurrentUser.GetUserId(User);
        var result = await _service.CreateOrGetChatAsync(currentUser, dto);
        return Ok(result);
    }
}
