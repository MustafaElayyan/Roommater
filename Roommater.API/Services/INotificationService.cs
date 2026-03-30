using Roommater.API.DTOs.Notification;

namespace Roommater.API.Services;

public interface INotificationService
{
    Task<List<NotificationDto>> GetMyNotificationsAsync(Guid userId, int page = 1, int pageSize = 50);
    Task MarkReadAsync(Guid id, Guid userId);
    Task MarkAllReadAsync(Guid userId);
}
