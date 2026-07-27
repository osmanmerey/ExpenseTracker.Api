using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ExpenseTracker.Api.Repositories;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<User?> GetByIdAsync(Guid id) =>
        _context.Users.FirstOrDefaultAsync(u => u.Id == id);

    public Task<User?> GetByIdNoTrackingAsync(Guid id) =>
        _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);

    public Task<User?> GetByEmailAsync(string normalizedEmail) =>
        _context.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail);

    public Task<bool> EmailExistsAsync(string normalizedEmail, Guid? excludingUserId = null) =>
        _context.Users.AnyAsync(u =>
            u.Email == normalizedEmail && (excludingUserId == null || u.Id != excludingUserId));

    public async Task AddAsync(User user) => await _context.Users.AddAsync(user);

    public void Remove(User user) => _context.Users.Remove(user);

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
