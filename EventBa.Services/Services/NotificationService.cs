using AutoMapper;
using EventBa.Model.Enums;
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

    public override async Task BeforeInsert(Notification entity, NotificationInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
    }

    public override IQueryable<Notification> AddInclude(IQueryable<Notification> query, NotificationSearchObject? search = null)
    {
        query = query.Include(x => x.User);
        return query;
    }

    public async Task<List<NotificationResponseDto>> GetMyNotifications()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var notifications = await _context.Notifications
            .Where(x => x.UserId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<NotificationResponseDto>>(notifications);
    }

    public async Task MarkAsRead(Guid notificationId)
    {
        var notification = await _context.Notifications.FindAsync(notificationId);
        if (notification != null)
        {
            notification.Status = NotificationStatus.Read;
            await _context.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsRead()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var notifications = await _context.Notifications
            .Where(x => x.UserId == currentUser.Id && x.Status != NotificationStatus.Read)
            .ToListAsync();

        foreach (var notification in notifications)
        {
            notification.Status = NotificationStatus.Read;
        }

        await _context.SaveChangesAsync();
    }
}