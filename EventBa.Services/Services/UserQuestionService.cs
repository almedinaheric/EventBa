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

public class UserQuestionService : BaseCRUDService<UserQuestionResponseDto, UserQuestion, UserQuestionSearchObject,
    UserQuestionInsertRequestDto, UserQuestionUpdateRequestDto>, IUserQuestionService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public UserQuestionService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(UserQuestion entity, UserQuestionInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
        
        // If EventId is provided, set it and find the event organizer as receiver
        if (insert.EventId.HasValue)
        {
            entity.EventId = insert.EventId.Value;
            
            // Get the event to find the organizer
            var eventEntity = await _context.Events
                .FirstOrDefaultAsync(e => e.Id == insert.EventId.Value);
            
            if (eventEntity == null)
                throw new UserException("Event not found.");
            
            // Set receiver to the event organizer
            entity.ReceiverId = eventEntity.OrganizerId;
            entity.IsQuestionForAdmin = false; // Event questions are for organizer, not admin
        }
        // If this is a question for admin (support question), find an admin user to set as receiver
        else if (insert.IsQuestionForAdmin)
        {
            // Load all roles and filter in memory to avoid EF Core enum translation issues
            var allRoles = await _context.Roles.ToListAsync();
            var adminRole = allRoles.FirstOrDefault(r => r.Name == RoleName.Admin);
            
            if (adminRole == null)
            {
                // Debug: List all roles to help diagnose
                var roleInfo = string.Join(", ", allRoles.Select(r => $"{r.Name} ({r.Id})"));
                throw new UserException($"Admin role not found. Available roles: {roleInfo}");
            }
            
            // Then, find a user with that role
            var adminUser = await _context.Users
                .FirstOrDefaultAsync(u => u.RoleId == adminRole.Id);
            
            if (adminUser == null)
                throw new UserException($"No user found with Admin role (RoleId: {adminRole.Id}).");
            
            entity.ReceiverId = adminUser.Id;
            entity.EventId = null; // Support questions are not event-related
            entity.IsQuestionForAdmin = true; // Ensure this is set correctly
        }
        // If receiverId is explicitly provided, use it
        else if (insert.ReceiverId.HasValue && insert.ReceiverId.Value != Guid.Empty)
        {
            entity.ReceiverId = insert.ReceiverId.Value;
        }
        else
        {
            throw new UserException("Either EventId or ReceiverId must be provided, or IsQuestionForAdmin must be true.");
        }
    }

    public override async Task<UserQuestionResponseDto> Insert(UserQuestionInsertRequestDto insert)
    {
        var set = _context.Set<UserQuestion>();
        var entity = _mapper.Map<UserQuestion>(insert);
        set.Add(entity);
        await BeforeInsert(entity, insert);
        await _context.SaveChangesAsync();
        
        // Reload entity with related data for notification and response
        var loadedEntity = await _context.UserQuestions
            .Include(x => x.User)
            .Include(x => x.Receiver)
            .FirstOrDefaultAsync(x => x.Id == entity.Id);
        
        if (loadedEntity != null)
        {
            await AfterInsert(loadedEntity, insert);
            // Return the loaded entity with all related data
            return _mapper.Map<UserQuestionResponseDto>(loadedEntity);
        }
        
        // Fallback to entity without related data if reload fails
        return _mapper.Map<UserQuestionResponseDto>(entity);
    }

    public async Task AfterInsert(UserQuestion entity, UserQuestionInsertRequestDto insert)
    {
        // Create notification for the receiver (event organizer or admin)
        var notification = new Notification
        {
            Title = "New Question Received",
            Content = $"{entity.User.FullName} asked: {entity.Question}",
            IsImportant = false,
            IsSystemNotification = false,
            EventId = entity.EventId
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        // Create UserNotification entry for the receiver
        var userNotification = new UserNotification
        {
            NotificationId = notification.Id,
            UserId = entity.ReceiverId,
            Status = NotificationStatus.Sent
        };

        _context.UserNotifications.Add(userNotification);
        await _context.SaveChangesAsync();
    }

    public override IQueryable<UserQuestion> AddInclude(IQueryable<UserQuestion> query, UserQuestionSearchObject? search = null)
    {
        query = query.Include(x => x.User)
                    .Include(x => x.Receiver);
        return query;
    }

    public async Task<List<UserQuestionResponseDto>> GetMyQuestions()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.Receiver)
            .Where(x => x.UserId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }

    public async Task<List<UserQuestionResponseDto>> GetQuestionsForMe()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.User)
            .Where(x => x.ReceiverId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }

    public async Task<List<UserQuestionResponseDto>> GetAdminQuestions()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.User)
            .Where(x => x.IsQuestionForAdmin == true && x.ReceiverId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }

    public async Task<List<UserQuestionResponseDto>> GetQuestionsForEvent(Guid eventId)
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.User)
            .Where(x => x.EventId == eventId && x.ReceiverId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }

    public override async Task<UserQuestionResponseDto> Update(Guid id, UserQuestionUpdateRequestDto update)
    {
        var set = _context.Set<UserQuestion>();
        var entity = await set
            .Include(x => x.User)
            .Include(x => x.Receiver)
            .FirstOrDefaultAsync(x => x.Id == id);
        
        if (entity == null)
            throw new UserException("Question not found");
        
        // Store old values to check if question was just answered
        var wasAlreadyAnswered = entity.IsAnswered;
        
        // Map the update to the entity
        _mapper.Map(update, entity);
        
        // If the question was just answered (wasn't answered before but is now), create notification
        if (!wasAlreadyAnswered && update.IsAnswered && !string.IsNullOrEmpty(update.Answer))
        {
            var notification = new Notification
            {
                Title = entity.EventId.HasValue 
                    ? "Your question about an event was answered" 
                    : "Your support question was answered",
                Content = entity.EventId.HasValue
                    ? $"{entity.Receiver.FullName} answered your question: {entity.Question}"
                    : $"{entity.Answer}",
                IsImportant = false,
                IsSystemNotification = false,
                EventId = entity.EventId
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            // Create UserNotification entry for the question sender
            var userNotification = new UserNotification
            {
                NotificationId = notification.Id,
                UserId = entity.UserId,
                Status = NotificationStatus.Sent
            };

            _context.UserNotifications.Add(userNotification);
        }
        
        await _context.SaveChangesAsync();
        return _mapper.Map<UserQuestionResponseDto>(entity);
    }
}