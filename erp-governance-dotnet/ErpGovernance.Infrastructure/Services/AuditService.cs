using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Entities;
using ErpGovernance.Infrastructure.Data;
using Microsoft.AspNetCore.Http;

namespace ErpGovernance.Infrastructure.Services;

public class AuditService : IAuditService
{
    private readonly ApplicationDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public AuditService(ApplicationDbContext db, ICurrentUserService currentUser, IHttpContextAccessor httpContextAccessor)
    {
        _db = db;
        _currentUser = currentUser;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task LogAsync(string action, string? entityType = null, int? entityId = null, string? details = null)
    {
        var ip = _httpContextAccessor.HttpContext?.Connection?.RemoteIpAddress?.ToString();
        var log = new AuditLog
        {
            UserId = _currentUser.IsAuthenticated ? _currentUser.UserId : null,
            Action = action,
            EntityType = entityType,
            EntityId = entityId,
            Details = details,
            IpAddress = ip,
            CreatedAt = DateTime.UtcNow
        };
        _db.AuditLogs.Add(log);
        await _db.SaveChangesAsync();
    }

    public async Task LogStatusChangeAsync(string entityType, int entityId, string? oldStatus, string newStatus, string? remarks = null)
    {
        var history = new StatusHistory
        {
            EntityType = entityType,
            EntityId = entityId,
            OldStatus = oldStatus,
            NewStatus = newStatus,
            ChangedById = _currentUser.IsAuthenticated ? _currentUser.UserId : null,
            Remarks = remarks,
            CreatedAt = DateTime.UtcNow
        };
        _db.StatusHistories.Add(history);
        await _db.SaveChangesAsync();
    }
}
