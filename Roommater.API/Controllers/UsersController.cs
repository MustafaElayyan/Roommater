using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.User;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Authorize]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("{uid:guid}")]
    public async Task<IActionResult> GetById(Guid uid)
    {
        var result = await _userService.GetByIdAsync(uid);
        return Ok(result);
    }

    [HttpPut("{uid:guid}")]
    public async Task<IActionResult> Update(Guid uid, [FromBody] UpdateProfileDto dto)
    {
        var currentUserId = CurrentUser.GetUserId(User);
        var result = await _userService.UpdateProfileAsync(uid, currentUserId, dto);
        return Ok(result);
    }
}
