using ExpenseTracker.Api.Common;
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
        return user is null ? null : ToResponse(user.Id, user.Name, user.Email, user.Role);
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

    public async Task<IEnumerable<UserResponseDto>> GetAllUsersAsync(CancellationToken cancellationToken = default)
    {
        var users = await _userRepository.GetAllAsync(cancellationToken);
        return users.Select(user => ToResponse(user.Id, user.Name, user.Email, user.Role)).ToList();
    }

    public async Task<UserAdminWriteOutcome> UpdateUserRoleAsync(
        Guid userId,
        string role,
        CancellationToken cancellationToken = default)
    {
        if (!UserRoles.IsValid(role))
            return UserAdminWriteOutcome.InvalidRole;

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return UserAdminWriteOutcome.NotFound;

        var nextRole = UserRoles.Normalize(role);
        if (UserRoles.IsAdmin(user.Role) && nextRole == UserRoles.User &&
            await IsLastAdminAsync(userId, cancellationToken))
        {
            return UserAdminWriteOutcome.LastAdmin;
        }

        user.Role = nextRole;
        await _userRepository.SaveChangesAsync(cancellationToken);
        return UserAdminWriteOutcome.Success;
    }

    public async Task<UserAdminWriteOutcome> DeleteUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
            return UserAdminWriteOutcome.NotFound;

        if (UserRoles.IsAdmin(user.Role) && await IsLastAdminAsync(userId, cancellationToken))
            return UserAdminWriteOutcome.LastAdmin;

        _userRepository.Remove(user);
        await _userRepository.SaveChangesAsync(cancellationToken);
        return UserAdminWriteOutcome.Success;
    }

    private async Task<bool> IsLastAdminAsync(Guid userId, CancellationToken cancellationToken)
    {
        var users = await _userRepository.GetAllAsync(cancellationToken);
        var adminIds = users
            .Where(u => UserRoles.IsAdmin(u.Role))
            .Select(u => u.Id)
            .ToList();

        return adminIds.Count == 1 && adminIds[0] == userId;
    }

    private static UserResponseDto ToResponse(Guid id, string name, string email, string role) => new()
    {
        Id = id,
        Name = name,
        Email = email,
        Role = UserRoles.Normalize(role)
    };
}
