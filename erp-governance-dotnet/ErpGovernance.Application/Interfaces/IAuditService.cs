namespace ErpGovernance.Application.Interfaces;

public interface IAuditService
{
    Task LogAsync(string action, string? entityType = null, int? entityId = null, string? details = null);
    Task LogStatusChangeAsync(string entityType, int entityId, string? oldStatus, string newStatus, string? remarks = null);
}
