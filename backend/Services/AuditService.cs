using backend.Data;
using backend.Models;

namespace backend.Services;

public interface IAuditService
{
    Task LogAsync(AuditLog entry);
}

public class AuditService : IAuditService
{
    private readonly AppDbContext _db;

    public AuditService(AppDbContext db) => _db = db;

    public async Task LogAsync(AuditLog entry)
    {
        entry.EventDateTime = DateTime.UtcNow;
        _db.AuditLogs.Add(entry);
        await _db.SaveChangesAsync();
    }
}
