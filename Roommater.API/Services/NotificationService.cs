using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Notification;
using Roommater.API.Middleware;

namespace Roommater.API.Services;

public class NotificationService : INotificationService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public NotificationService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<NotificationDto>> GetMyNotificationsAsync(Guid userId, int page = 1, int pageSize = 50)
    {
        var items = await _db.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return items.Select(_mapper.Map<NotificationDto>).ToList();
    }

    public async Task MarkReadAsync(Guid id, Guid userId)
    {
        var item = await _db.Notifications.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "Notification not found.");

        item.IsRead = true;
        await _db.SaveChangesAsync();
    }

    public async Task MarkAllReadAsync(Guid userId)
    {
        var items = await _db.Notifications.Where(n => n.UserId == userId && !n.IsRead).ToListAsync();
        foreach (var item in items)
        {
            item.IsRead = true;
        }

        await _db.SaveChangesAsync();
    }
}
