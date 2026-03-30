using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.User;
using Roommater.API.Middleware;

namespace Roommater.API.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public UserService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<UserDto> GetByIdAsync(Guid id)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == id)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "User not found.");

        return _mapper.Map<UserDto>(user);
    }

    public async Task<UserDto> UpdateProfileAsync(Guid id, Guid currentUserId, UpdateProfileDto dto)
    {
        if (id != currentUserId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "You can only update your own profile.");
        }

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == id)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "User not found.");

        user.DisplayName = dto.DisplayName.Trim();
        user.Bio = dto.Bio?.Trim();
        user.PhotoUrl = dto.PhotoUrl?.Trim();
        user.Age = dto.Age;
        user.Occupation = dto.Occupation?.Trim();
        user.Location = dto.Location?.Trim();

        await _db.SaveChangesAsync();

        return _mapper.Map<UserDto>(user);
    }
}
