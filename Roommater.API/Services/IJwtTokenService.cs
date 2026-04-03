using Roommater.API.Models;

namespace Roommater.API.Services;

public interface IJwtTokenService
{
    string GenerateToken(User user);
}
