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

    public async Task<UserResponseDto?> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdNoTrackingAsync(userId, cancellationToken);
        return user is null ? null : ToResponse(user.Id, user.Name, user.Email);
    }

    public async Task<UserUpdateOutcome> UpdateCurrentUserAsync(
        Guid userId,
        UserUpdateDto request,
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await _userRepository.EmailExistsAsync(normalizedEmail, excludingUserId: userId, cancellationToken))
            return UserUpdateOutcome.EmailAlreadyExists;

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return UserUpdateOutcome.NotFound;

        user.Name = request.Name.Trim();
        user.Email = normalizedEmail;
        await _userRepository.SaveChangesAsync(cancellationToken);

        return UserUpdateOutcome.Success;
    }

    public async Task<bool> DeleteCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return false;

        _userRepository.Remove(user);
        await _userRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    // --- YENİ EKLENEN ADMIN METOTLARI ---

    public async Task<IEnumerable<UserResponseDto>> GetAllUsersAsync(CancellationToken cancellationToken = default)
    {
        // Not: IUserRepository içinde GetAllAsync metodu olduğundan emin ol.
        var users = await _userRepository.GetAllAsync(cancellationToken); 
        return users.Select(user => ToResponse(user.Id, user.Name, user.Email)).ToList();
    }

    public async Task<bool> UpdateUserRoleAsync(Guid userId, string role, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return false;

        // User modelinde 'Role' alanı varsa güncellenir
        user.Role = role.Trim().ToLowerInvariant(); 
        await _userRepository.SaveChangesAsync(cancellationToken);
        
        return true;
    }

    public async Task<bool> DeleteUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return false;

        _userRepository.Remove(user);
        await _userRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static UserResponseDto ToResponse(Guid id, string name, string email) => new()
    {
        Id = id,
        Name = name,
        Email = email
    };
}