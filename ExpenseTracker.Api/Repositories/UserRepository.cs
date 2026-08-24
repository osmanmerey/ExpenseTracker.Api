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

    public async Task<IEnumerable<User>> GetAllAsync(CancellationToken cancellationToken = default) =>
        await _context.Users.AsNoTracking().ToListAsync(cancellationToken);

    public Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        _context.Users.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

    public Task<User?> GetByIdNoTrackingAsync(Guid id, CancellationToken cancellationToken = default) =>
        _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

    public Task<User?> GetByEmailAsync(string normalizedEmail, CancellationToken cancellationToken = default) =>
        _context.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail, cancellationToken);

    public Task<bool> EmailExistsAsync(
        string normalizedEmail,
        Guid? excludingUserId = null,
        CancellationToken cancellationToken = default) =>
        _context.Users.AnyAsync(
            u => u.Email == normalizedEmail && (excludingUserId == null || u.Id != excludingUserId),
            cancellationToken);

    public async Task AddAsync(User user, CancellationToken cancellationToken = default) =>
        await _context.Users.AddAsync(user, cancellationToken);

    public void Remove(User user) => _context.Users.Remove(user);

    public Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);
}
