using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Roommater.API.DTOs.Auth;
using Roommater.API.DTOs.User;
using Roommater.API.Models;
using Roommater.API.Services;

namespace Roommater.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly JwtService _jwtService;
    private readonly IWebHostEnvironment _env;

    public AuthController(IAuthService authService, JwtService jwtService, IWebHostEnvironment env)
    {
        _authService = authService;
        _jwtService = jwtService;
        _env = env;
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

    [HttpPost("dev-bypass")]
    [AllowAnonymous]
    public IActionResult DevBypass()
    {
        if (!_env.IsDevelopment())
        {
            return NotFound();
        }

        var devUser = new User
        {
            Id = Guid.Empty,
            Email = "dev@test.com",
            DisplayName = "Development User"
        };

        var response = new AuthResponseDto
        {
            Token = _jwtService.GenerateToken(devUser),
            User = new UserDto
            {
                Uid = devUser.Id,
                Email = devUser.Email,
                DisplayName = devUser.DisplayName,
                PhotoUrl = devUser.PhotoUrl,
                Bio = devUser.Bio,
                Age = devUser.Age,
                Occupation = devUser.Occupation,
                Location = devUser.Location
            }
        };

        return Ok(response);
    }

    [HttpDelete("signout")]
    [Authorize]
    public async Task<IActionResult> SignOutCurrentUser()
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
