using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Auth;
using Roommater.API.DTOs.User;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly IJwtTokenService _jwtService;
    private readonly IMapper _mapper;

    public AuthService(AppDbContext db, IJwtTokenService jwtService, IMapper mapper)
    {
        _db = db;
        _jwtService = jwtService;
        _mapper = mapper;
    }

    public async Task<AuthResponseDto> SignUpAsync(SignUpDto dto)
    {
        var normalizedEmail = dto.Email.Trim().ToLowerInvariant();
        var exists = await _db.Users.AnyAsync(u => u.Email == normalizedEmail);
        if (exists)
        {
            throw new ApiException(HttpStatusCode.Conflict, "Email already in use.");
        }

        var user = new User
        {
            Email = normalizedEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            DisplayName = dto.DisplayName.Trim()
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return new AuthResponseDto
        {
            Token = _jwtService.GenerateToken(user),
            User = _mapper.Map<UserDto>(user)
        };
    }

    public async Task<AuthResponseDto> SignInAsync(SignInDto dto)
    {
        var normalizedEmail = dto.Email.Trim().ToLowerInvariant();
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail);
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
        {
            throw new ApiException(HttpStatusCode.Unauthorized, "Invalid email or password.");
        }

        return new AuthResponseDto
        {
            Token = _jwtService.GenerateToken(user),
            User = _mapper.Map<UserDto>(user)
        };
    }

    /// Sign-out is a no-op for stateless JWT authentication.
    /// The client clears its stored token locally; the server-issued JWT
    /// remains cryptographically valid until its expiry but can no longer
    /// be used once the client discards it.
    public Task SignOutAsync(Guid userId)
    {
        return Task.CompletedTask;
    }

    public async Task<UserDto> GetMeAsync(Guid userId)
    {
        var user = await _db.Users.FindAsync(userId);
        if (user is null)
        {
            throw new ApiException(HttpStatusCode.NotFound, "User not found.");
        }

        return _mapper.Map<UserDto>(user);
    }
}
