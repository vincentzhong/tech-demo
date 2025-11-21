using BookstoreApi.Models;

namespace BookstoreApi.Services;

public interface IJwtService
{
    string GenerateToken(User user);
}
