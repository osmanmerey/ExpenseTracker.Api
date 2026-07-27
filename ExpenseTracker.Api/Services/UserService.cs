using ExpenseTracker.Api.DTOs;
using ExpenseTracker.Api.Repositories;
using ExpenseTracker.Api.Services.Results;

namespace ExpenseTracker.Api.Services;

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;

    public UserService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UserResponseDto?> GetCurrentUserAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdNoTrackingAsync(userId);
        return user is null ? null : ToResponse(user.Id, user.Name, user.Email);
    }

    public async Task<UserUpdateOutcome> UpdateCurrentUserAsync(Guid userId, UserUpdateDto request)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _userRepository.EmailExistsAsync(normalizedEmail, excludingUserId: userId))
            return UserUpdateOutcome.EmailAlreadyExists;

        var user = await _userRepository.GetByIdAsync(userId);
        if (user is null)
            return UserUpdateOutcome.NotFound;

        user.Name = request.Name.Trim();
        user.Email = normalizedEmail;
        await _userRepository.SaveChangesAsync();

        return UserUpdateOutcome.Success;
    }

    public async Task<bool> DeleteCurrentUserAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user is null)
            return false;

        _userRepository.Remove(user);
        await _userRepository.SaveChangesAsync();
        return true;
    }

    private static UserResponseDto ToResponse(Guid id, string name, string email) => new()
    {
        Id = id,
        Name = name,
        Email = email
    };
}
