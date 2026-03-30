using System.Net;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.Middleware;

namespace Roommater.API.Services;

public static class ServiceGuards
{
    public static async Task EnsureHouseholdMemberAsync(AppDbContext db, Guid householdId, Guid userId)
    {
        var member = await db.Users.AnyAsync(u => u.Id == userId && u.HouseholdId == householdId);
        if (!member)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Access denied for this household.");
        }
    }
}
