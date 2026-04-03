using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using Roommater.API.Middleware;

namespace Roommater.API.Services;

public static class CurrentUser
{
    public static Guid GetUserId(ClaimsPrincipal user)
    {
        var raw = user.FindFirstValue(JwtRegisteredClaimNames.Sub) ?? user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (raw is null || !Guid.TryParse(raw, out var userId))
        {
            throw new ApiException(HttpStatusCode.Unauthorized, "Invalid authentication token.");
        }

        return userId;
    }
}
