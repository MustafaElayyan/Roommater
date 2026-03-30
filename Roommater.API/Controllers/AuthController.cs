using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Auth;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("signup")]
    [AllowAnonymous]
    public async Task<IActionResult> SignUp([FromBody] SignUpDto dto)
    {
        var result = await _authService.SignUpAsync(dto);
        return Ok(result);
    }

    [HttpPost("signin")]
    [AllowAnonymous]
    public async Task<IActionResult> SignIn([FromBody] SignInDto dto)
    {
        var result = await _authService.SignInAsync(dto);
        return Ok(result);
    }

    [HttpDelete("signout")]
    [Authorize]
    public async Task<IActionResult> SignOut()
    {
        var userId = CurrentUser.GetUserId(User);
        await _authService.SignOutAsync(userId);
        return NoContent();
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> Me()
    {
        var userId = CurrentUser.GetUserId(User);
        var result = await _authService.GetMeAsync(userId);
        return Ok(result);
    }
}
