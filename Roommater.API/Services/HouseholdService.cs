using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Household;
using Roommater.API.DTOs.User;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class HouseholdService : IHouseholdService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public HouseholdService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<HouseholdDto> CreateAsync(Guid userId, CreateHouseholdDto dto)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == userId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "User not found.");

        var household = new Household
        {
            Name = dto.Name.Trim(),
            InviteCode = await GenerateInviteCodeAsync(),
            CreatedByUserId = userId
        };

        _db.Households.Add(household);
        user.HouseholdId = household.Id;
        await _db.SaveChangesAsync();

        return await GetByIdAsync(household.Id, userId);
    }

    public async Task<HouseholdDto> JoinAsync(Guid userId, JoinHouseholdDto dto)
    {
        var household = await _db.Households.FirstOrDefaultAsync(h => h.InviteCode == dto.InviteCode.ToUpperInvariant())
                        ?? throw new ApiException(HttpStatusCode.NotFound, "Invalid invite code.");

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == userId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "User not found.");

        user.HouseholdId = household.Id;
        await _db.SaveChangesAsync();

        return await GetByIdAsync(household.Id, userId);
    }

    public async Task<HouseholdDto> GetByIdAsync(Guid householdId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var household = await _db.Households
            .Include(h => h.Members)
            .FirstOrDefaultAsync(h => h.Id == householdId)
            ?? throw new ApiException(HttpStatusCode.NotFound, "Household not found.");

        var dto = _mapper.Map<HouseholdDto>(household);
        dto.Members = household.Members.Select(_mapper.Map<UserDto>).ToList();
        return dto;
    }

    public async Task<List<UserDto>> GetMembersAsync(Guid householdId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var members = await _db.Users
            .Where(u => u.HouseholdId == householdId)
            .OrderBy(u => u.DisplayName)
            .ToListAsync();

        return members.Select(_mapper.Map<UserDto>).ToList();
    }

    public async Task RemoveMemberAsync(Guid householdId, Guid actorUserId, Guid memberUserId)
    {
        var household = await _db.Households.FirstOrDefaultAsync(h => h.Id == householdId)
                        ?? throw new ApiException(HttpStatusCode.NotFound, "Household not found.");

        if (household.CreatedByUserId != actorUserId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only creator can remove members.");
        }

        var member = await _db.Users.FirstOrDefaultAsync(u => u.Id == memberUserId && u.HouseholdId == householdId)
                     ?? throw new ApiException(HttpStatusCode.NotFound, "Member not found.");

        if (member.Id == household.CreatedByUserId)
        {
            throw new ApiException(HttpStatusCode.BadRequest, "Cannot remove household creator.");
        }

        member.HouseholdId = null;
        await _db.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid householdId, Guid actorUserId)
    {
        var household = await _db.Households.FirstOrDefaultAsync(h => h.Id == householdId)
                        ?? throw new ApiException(HttpStatusCode.NotFound, "Household not found.");

        if (household.CreatedByUserId != actorUserId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only creator can delete household.");
        }

        var members = await _db.Users.Where(u => u.HouseholdId == householdId).ToListAsync();
        foreach (var member in members)
        {
            member.HouseholdId = null;
        }

        _db.Households.Remove(household);
        await _db.SaveChangesAsync();
    }

    private async Task<string> GenerateInviteCodeAsync()
    {
        const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        while (true)
        {
            var code = new string(Enumerable.Repeat(chars, 6)
                .Select(s => s[Random.Shared.Next(s.Length)])
                .ToArray());

            var exists = await _db.Households.AnyAsync(h => h.InviteCode == code);
            if (!exists)
            {
                return code;
            }
        }
    }
}
