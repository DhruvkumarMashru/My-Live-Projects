namespace ErpGovernance.Application.Interfaces;

public interface INotificationService
{
    Task SendAsync(int userId, string title, string message, string type = "info", string? entityType = null, int? entityId = null);
    Task<int> GetUnreadCountAsync(int userId);
    Task MarkAllReadAsync(int userId);
    Task MarkReadAsync(int notificationId, int userId);
}
