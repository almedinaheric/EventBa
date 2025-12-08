using AutoMapper;
using EventBa.Model.Enums;
using EventBa.Model.Helpers;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class NotificationService : BaseCRUDService<NotificationResponseDto, Notification, NotificationSearchObject,
    NotificationInsertRequestDto, NotificationUpdateRequestDto>, INotificationService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public NotificationService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task<NotificationResponseDto> Insert(NotificationInsertRequestDto insert)
    {
        // Create the notification first
        var result = await base.Insert(insert);
        
        // Get the created notification entity
        var notification = await _context.Notifications.FindAsync(Guid.Parse(result.Id.ToString()));
        if (notification == null)
        {
            throw new UserException("Failed to create notification");
        }

        // Create UserNotification entries for all users if system notification, or specific user(s)
        if (insert.IsSystemNotification)
        {
            // For system notifications, create entries for all users
            var allUsers = await _context.Users.Select(u => u.Id).ToListAsync();
            foreach (var userId in allUsers)
            {
                var userNotification = new UserNotification
                {
                    NotificationId = notification.Id,
                    UserId = userId,
                    Status = NotificationStatus.Sent
                };
                _context.UserNotifications.Add(userNotification);
            }
        }
        else
        {
            // For regular notifications, create entry for specific user(s)
            var targetUserIds = new List<Guid>();
            
            // If UserId is specified in the request, use it
            if (insert.UserId.HasValue)
            {
                targetUserIds.Add(insert.UserId.Value);
            }
            else
            {
                // Otherwise, use current user
                var currentUser = await _userService.GetUserEntityAsync();
                targetUserIds.Add(currentUser.Id);
            }

            foreach (var userId in targetUserIds)
            {
                var userNotification = new UserNotification
                {
                    NotificationId = notification.Id,
                    UserId = userId,
                    Status = NotificationStatus.Sent
                };
                _context.UserNotifications.Add(userNotification);
            }
        }

        await _context.SaveChangesAsync();
        return result;
    }

    public override IQueryable<Notification> AddInclude(IQueryable<Notification> query, NotificationSearchObject? search = null)
    {
        query = query.Include(x => x.UserNotifications).ThenInclude(x => x.User);
        return query;
    }

    public async Task<List<NotificationResponseDto>> GetMyNotifications()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var userNotifications = await _context.UserNotifications
            .Include(un => un.Notification)
                .ThenInclude(n => n.Event)
            .Where(un => un.UserId == currentUser.Id)
            .OrderByDescending(un => un.Notification.CreatedAt)
            .ToListAsync();

        var responseDtos = userNotifications.Select(un => new NotificationResponseDto
        {
            Id = un.Notification.Id,
            CreatedAt = un.Notification.CreatedAt,
            UpdatedAt = un.Notification.UpdatedAt,
            EventId = un.Notification.EventId,
            IsSystemNotification = un.Notification.IsSystemNotification,
            Title = un.Notification.Title,
            Content = un.Notification.Content,
            IsImportant = un.Notification.IsImportant,
            Status = un.Status
        }).ToList();

        return responseDtos;
    }
    
    public async Task<int> GetUnreadNotificationCount()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        return await _context.UserNotifications
            .Where(un => un.UserId == currentUser.Id && un.Status != NotificationStatus.Read)
            .CountAsync();
    }

    public async Task MarkAsRead(Guid notificationId)
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var userNotification = await _context.UserNotifications
            .FirstOrDefaultAsync(un => un.NotificationId == notificationId && un.UserId == currentUser.Id);
        
        if (userNotification != null)
        {
            userNotification.Status = NotificationStatus.Read;
            await _context.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsRead()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var userNotifications = await _context.UserNotifications
            .Where(un => un.UserId == currentUser.Id && un.Status != NotificationStatus.Read)
            .ToListAsync();

        foreach (var userNotification in userNotifications)
        {
            userNotification.Status = NotificationStatus.Read;
        }

        await _context.SaveChangesAsync();
    }

    public async Task<List<NotificationResponseDto>> GetSystemNotifications()
    {
        var notifications = await _context.Notifications
            .Where(x => x.IsSystemNotification == true)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        // Map notifications with a default status (for admin view, status is not relevant)
        return notifications.Select(n => new NotificationResponseDto
        {
            Id = n.Id,
            CreatedAt = n.CreatedAt,
            UpdatedAt = n.UpdatedAt,
            EventId = n.EventId,
            IsSystemNotification = n.IsSystemNotification,
            Title = n.Title,
            Content = n.Content,
            IsImportant = n.IsImportant,
            Status = NotificationStatus.Sent // Default status for admin view
        }).ToList();
    }

    public override async Task<NotificationResponseDto> Delete(Guid id)
    {
        var currentUser = await _userService.GetUserEntityAsync();
        
        // For user notifications, only delete the UserNotification entry (not the notification itself)
        var userNotification = await _context.UserNotifications
            .Include(un => un.Notification)
            .FirstOrDefaultAsync(un => un.NotificationId == id && un.UserId == currentUser.Id);
        
        if (userNotification != null)
        {
            var notification = userNotification.Notification;
            _context.UserNotifications.Remove(userNotification);
            await _context.SaveChangesAsync();
            
            // Return the notification with the user's status (which was just deleted)
            return new NotificationResponseDto
            {
                Id = notification.Id,
                CreatedAt = notification.CreatedAt,
                UpdatedAt = notification.UpdatedAt,
                EventId = notification.EventId,
                IsSystemNotification = notification.IsSystemNotification,
                Title = notification.Title,
                Content = notification.Content,
                IsImportant = notification.IsImportant,
                Status = userNotification.Status
            };
        }
        
        throw new UserException("Notification not found");
    }
}