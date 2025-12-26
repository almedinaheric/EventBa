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
    private readonly IRabbitMQProducer _rabbitMQProducer;

    public NotificationService(EventBaDbContext context, IMapper mapper, IUserService userService, IRabbitMQProducer rabbitMQProducer) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
        _rabbitMQProducer = rabbitMQProducer;
    }

    public override async Task<NotificationResponseDto> Insert(NotificationInsertRequestDto insert)
    {
        var result = await base.Insert(insert);
        
        var notification = await _context.Notifications.FindAsync(Guid.Parse(result.Id.ToString()));
        if (notification == null)
        {
            throw new UserException("Failed to create notification");
        }

        if (insert.IsSystemNotification)
        {
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
            var targetUserIds = new List<Guid>();
            
            if (insert.UserId.HasValue)
            {
                targetUserIds.Add(insert.UserId.Value);
            }
            else
            {
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
        var recipientUserIds = insert.IsSystemNotification 
            ? await _context.Users.Select(u => u.Id).ToListAsync()
            : insert.UserId.HasValue 
                ? new List<Guid> { insert.UserId.Value }
                : new List<Guid> { (await _userService.GetUserEntityAsync()).Id };

        var recipientUsers = await _context.Users
            .Where(u => recipientUserIds.Contains(u.Id))
            .ToListAsync();

        foreach (var recipient in recipientUsers)
        {
            var emailModel = new EmailModel
            {
                Sender = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "noreply@eventba.com",
                Recipient = recipient.Email,
                Subject = insert.IsImportant ? $"🔔 Important: {insert.Title}" : insert.Title,
                Content = $@"
Hello {recipient.FirstName} {recipient.LastName},

{insert.Content}

{(insert.IsImportant ? "\n⚠️ This is an important notification." : "")}

You can also view this notification in the EventBa app.

Best regards,
EventBa Team
"
            };

            _rabbitMQProducer.SendMessage(emailModel);
        }

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
            Status = NotificationStatus.Sent
        }).ToList();
    }

    public override async Task<NotificationResponseDto> Delete(Guid id)
    {
        var currentUser = await _userService.GetUserEntityAsync();
        
        var userNotification = await _context.UserNotifications
            .Include(un => un.Notification)
            .FirstOrDefaultAsync(un => un.NotificationId == id && un.UserId == currentUser.Id);
        
        if (userNotification != null)
        {
            var notification = userNotification.Notification;
            _context.UserNotifications.Remove(userNotification);
            await _context.SaveChangesAsync();
            
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