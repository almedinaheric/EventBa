using AutoMapper;
using EventBa.Model.Enums;
using EventBa.Model.Helpers;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace EventBa.Services.Services;

public class EventService : BaseCRUDService<EventResponseDto, Event, EventSearchObject,
    EventInsertRequestDto, EventUpdateRequestDto>, IEventService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    
    private readonly IUserService _userService;
    private readonly IRecommendedEventService _recommendedEventService;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public EventService(EventBaDbContext context, IMapper mapper, IUserService userService, IRecommendedEventService recommendedEventService, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
        _recommendedEventService = recommendedEventService;
        _httpContextAccessor = httpContextAccessor;
    }
    
    public override async Task BeforeInsert(Event entity, EventInsertRequestDto insert)
    {
        entity.Organizer = await _userService.GetUserEntityAsync();
    }

    public override async Task<EventResponseDto> Update(Guid id, EventUpdateRequestDto update)
    {
        var set = _context.Set<Event>();
        var entity = await set.FindAsync(id);
        
        if (entity == null)
            throw new UserException("Event not found");
        
        var oldCoverImageId = entity.CoverImageId;
        
        _mapper.Map(update, entity);
        
        if (update.CoverImageId.HasValue && oldCoverImageId.HasValue && 
            update.CoverImageId.Value != oldCoverImageId.Value)
        {
            var oldCoverImage = await _context.Images.FindAsync(oldCoverImageId.Value);
            if (oldCoverImage != null)
            {
                _context.Images.Remove(oldCoverImage);
            }
        }
        else if (!update.CoverImageId.HasValue && oldCoverImageId.HasValue)
        {
            entity.CoverImageId = oldCoverImageId;
        }
        
        await _context.SaveChangesAsync();
        var entityWithIncludes = await AddInclude(_context.Set<Event>().Where(e => e.Id == id))
            .FirstOrDefaultAsync();
        
        if (entityWithIncludes != null)
        {
            return _mapper.Map<EventResponseDto>(entityWithIncludes);
        }
        
        return _mapper.Map<EventResponseDto>(entity);
    }

    public override async Task<EventResponseDto> Insert(EventInsertRequestDto insert)
    {
        var result = await base.Insert(insert);
        
        var entityWithIncludes = await AddInclude(_context.Set<Event>().Where(e => e.Id == Guid.Parse(result.Id.ToString())))
            .FirstOrDefaultAsync();
        
        if (entityWithIncludes != null)
        {
            result = _mapper.Map<EventResponseDto>(entityWithIncludes);
        }
        
        return result;
    }

    public override async Task<EventResponseDto> Delete(Guid id)
    {
        var entity = await _context.Events.FindAsync(id);
        if (entity == null)
        {
            throw new UserException("Event not found");
        }

        entity.IsPublished = false;
        await _context.SaveChangesAsync();
        return _mapper.Map<EventResponseDto>(entity);
    }

    public override IQueryable<Event> AddInclude(IQueryable<Event> query, EventSearchObject? search = null)
    {
        query = query.Include(x => x.Organizer)
                    .Include(x => x.Category)
                    .Include(x => x.CoverImage)
                    .Include(x => x.EventGalleryImages)
                        .ThenInclude(x => x.Image)
                    .Include(x => x.EventReviews)
                    .Include(x => x.Tickets);

        return query;
    }

    public override IQueryable<Event> AddFilter(IQueryable<Event> query, EventSearchObject? search = null)
    {
        if (search?.Type.HasValue == true)
        {
            query = query.Where(x => x.Type == search.Type.Value);
        }
        
        if (!string.IsNullOrWhiteSpace(search?.SearchTerm))
        {
            var searchTerm = search.SearchTerm.ToLower();
            query = query.Where(x => 
                x.Title.ToLower().Contains(searchTerm) || 
                (x.Description != null && x.Description.ToLower().Contains(searchTerm))
            );
        }
        
        query = query.Where(x => x.IsPublished);

        try
        {
            var userEmail = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;
            if (!string.IsNullOrEmpty(userEmail))
            {
                var currentUser = _context.Users.FirstOrDefault(u => u.Email.Equals(userEmail));
                if (currentUser != null)
                {
                    query = query.Where(x => x.OrganizerId != currentUser.Id);
                }
            }
        }
        catch
        {
        }

        return query;
    }

    public async Task<List<EventResponseDto>> GetMyEvents()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var events = await _context.Events
            .Include(x => x.Category)
            .Include(x => x.CoverImage)
            .Include(x => x.EventGalleryImages)
            .ThenInclude(egi => egi.Image)
            .Where(x => x.OrganizerId == currentUser.Id)
            .Where(x => x.IsPublished)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(events);
    }
    
    public async Task<List<EventResponseDto>> GetEventsByOrganizer(Guid organizerId)
    {
        var events = await _context.Events
            .Include(x => x.Category)
            .Include(x => x.CoverImage)
            .Include(x => x.Tickets)
            .Where(x => x.OrganizerId == organizerId)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(events);
    }
    
    public override async Task<EventResponseDto> GetById(Guid id)
    {
        var entity = await _context.Events
            .Include(x => x.Organizer)
            .Include(x => x.Category)
            .Include(x => x.CoverImage)
            .Include(x => x.EventGalleryImages)
                .ThenInclude(egi => egi.Image)
            .Include(x => x.EventReviews)
            .Include(x => x.Tickets)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (entity == null)
            throw new UserException("Event not found");

        return _mapper.Map<EventResponseDto>(entity);
    }
    public async Task<List<EventResponseDto>> GetRecommendedEvents()
    {
        var currentUser = await _userService.GetUserAsync();
        return await _recommendedEventService.GetRecommendedEventsForUser(currentUser.Id);
    }
    
    public async Task<List<EventResponseDto>> GetPublicEvents()
    {
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
        }

        var query = _context.Events
            .Where(e => e.Type == EventType.Public && e.IsPublished);
        
        if (currentUser != null)
        {
            query = query.Where(e => e.OrganizerId != currentUser.Id);
        }

        var publicEvents = await query
            .Include(e => e.Category)
            .Include(e => e.CoverImage)
            .Include(e => e.Tickets)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(publicEvents);
    }

    public async Task<List<EventResponseDto>> GetPrivateEvents()
    {
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
        }

        var query = _context.Events
            .Where(e => e.Type == EventType.Private && e.IsPublished);
        
        if (currentUser != null)
        {
            query = query.Where(e => e.OrganizerId != currentUser.Id);
        }

        var privateEvents = await query
            .Include(e => e.Category)
            .Include(e => e.CoverImage)
            .Include(e => e.Tickets)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(privateEvents);
    }

    public async Task<List<EventResponseDto>> GetEventsByCategoryId(Guid categoryId)
    {
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
        }

        var query = _context.Events
            .Where(e => e.Category.Id == categoryId && e.IsPublished);
        
        if (currentUser != null)
        {
            query = query.Where(e => e.OrganizerId != currentUser.Id);
        }

        var events = await query
            .Include(e => e.Category)
            .Include(e => e.CoverImage)
            .Include(e => e.Tickets)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(events);
    }
    
    public async Task<List<EventResponseDto>> GetUserFavoriteEventsAsync()
    {
        var currentUser = await _userService.GetUserAsync();

        var user = await _context.Users
            .Include(u => u.FavoriteEvents)
                .ThenInclude(e => e.Category)
            .Include(u => u.FavoriteEvents)
                .ThenInclude(e => e.CoverImage)
            .Include(u => u.FavoriteEvents)
                .ThenInclude(e => e.Tickets)
            .FirstOrDefaultAsync(u => u.Id == currentUser.Id);

        if (user == null)
            throw new UserException("User not found");

        var publishedFavorites = user.FavoriteEvents
            .Where(e => e.IsPublished)
            .ToList();

        return _mapper.Map<List<EventResponseDto>>(publishedFavorites);
    }

    public async Task<bool> ToggleFavoriteEventAsync(Guid eventId)
    {
        var currentUser = await _userService.GetUserAsync();

        var user = await _context.Users
            .Include(u => u.FavoriteEvents)
            .FirstOrDefaultAsync(u => u.Id == currentUser.Id);

        if (user == null)
            throw new UserException("User not found");

        var targetEvent = await _context.Events.FindAsync(eventId);
        if (targetEvent == null)
            throw new UserException("Event not found");

        var isAlreadyFavorite = user.FavoriteEvents.Any(e => e.Id == eventId);

        if (isAlreadyFavorite)
        {
            user.FavoriteEvents.Remove(targetEvent);
        }
        else
        {
            user.FavoriteEvents.Add(targetEvent);
        }

        await _context.SaveChangesAsync();
        return true;
    }
    
    public async Task<EventStatisticsResponseDto> GetEventStatistics(Guid eventId)
    {
        var eventEntity = await _context.Events
            .Include(x => x.Tickets)
            .ThenInclude(x => x.TicketPurchases)
            .Include(x => x.EventReviews)
            .Include(x => x.EventStatistics)
            .FirstOrDefaultAsync(x => x.Id == eventId);

        if (eventEntity == null)
            return null;

        var currentUser = await _userService.GetUserEntityAsync();
        
        if (currentUser.Role == null)
        {
            currentUser = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Id == currentUser.Id);
        }
        
        var isAdmin = currentUser?.Role?.Name == RoleName.Admin;
        var isOrganizer = eventEntity.OrganizerId == currentUser.Id;

        if (!isAdmin && !isOrganizer)
        {
            throw new UserException("You do not have permission to view statistics for this event.");
        }

        var eventEndDateTime = new DateTime(
            eventEntity.EndDate.Year,
            eventEntity.EndDate.Month,
            eventEntity.EndDate.Day,
            eventEntity.EndTime.Hour,
            eventEntity.EndTime.Minute,
            eventEntity.EndTime.Second
        );
        var isPast = eventEndDateTime < DateTime.Now;

        if (isPast)
        {
            var existingStat = await _context.EventStatistics
                .FirstOrDefaultAsync(x => x.EventId == eventId);

            if (existingStat != null)
            {
                return new EventStatisticsResponseDto
                {
                    EventId = eventId,
                    TotalTicketsSold = existingStat.TotalTicketsSold,
                    TotalRevenue = existingStat.TotalRevenue,
                    CurrentAttendees = existingStat.TotalTicketsSold,
                    AverageRating = (double)existingStat.AverageRating
                };
            }
            else
            {
                var soldTickets = eventEntity.Tickets.Sum(x => x.TicketPurchases.Count);
                var revenue = eventEntity.Tickets.Sum(x => x.TicketPurchases.Sum(p => p.PricePaid));
                var averageRating = eventEntity.EventReviews.Any() 
                    ? (double)eventEntity.EventReviews.Average(x => x.Rating) 
                    : 0.0;

                var newStat = new EventStatistic
                {
                    EventId = eventId,
                    TotalTicketsSold = soldTickets,
                    TotalRevenue = revenue,
                    AverageRating = (decimal)averageRating,
                    TotalViews = 0,
                    TotalFavorites = 0
                };
                _context.EventStatistics.Add(newStat);
                await _context.SaveChangesAsync();

                return new EventStatisticsResponseDto
                {
                    EventId = eventId,
                    TotalTicketsSold = soldTickets,
                    TotalRevenue = revenue,
                    CurrentAttendees = soldTickets,
                    AverageRating = averageRating
                };
            }
        }
        else
        {
            var soldTickets = eventEntity.Tickets.Sum(x => x.TicketPurchases.Count);
            var revenue = eventEntity.Tickets.Sum(x => x.TicketPurchases.Sum(p => p.PricePaid));
            var averageRating = 0.0;

            return new EventStatisticsResponseDto
            {
                EventId = eventId,
                TotalTicketsSold = soldTickets,
                TotalRevenue = revenue,
                CurrentAttendees = eventEntity.CurrentAttendees,
                AverageRating = averageRating
            };
        }
    }

    public async Task AddGalleryImages(Guid eventId, List<Guid> imageIds)
    {
        var eventEntity = await _context.Events.FindAsync(eventId);
        if (eventEntity == null)
        {
            throw new UserException("Event not found");
        }
        
        int order = 0;
        foreach (var imageId in imageIds)
        {
            var image = await _context.Images.FindAsync(imageId);
            if (image != null)
            {
                image.ImageType = ImageType.EventGallery;
                image.EventId = eventId;
                
                var existingLink = await _context.EventGalleryImages
                    .FirstOrDefaultAsync(x => x.EventId == eventId && x.ImageId == imageId);
                
                if (existingLink == null)
                {
                    var now = DateTime.Now;
                    var galleryImage = new EventGalleryImage
                    {
                        EventId = eventId,
                        ImageId = imageId,
                        Order = order++,
                        CreatedAt = now,
                        UpdatedAt = now
                    };
                    _context.EventGalleryImages.Add(galleryImage);
                }
            }
        }

        await _context.SaveChangesAsync();
    }

    public async Task ReplaceGalleryImages(Guid eventId, List<Guid> imageIds)
    {
        var eventEntity = await _context.Events
            .Include(e => e.EventGalleryImages)
            .FirstOrDefaultAsync(e => e.Id == eventId);
            
        if (eventEntity == null)
        {
            throw new UserException("Event not found");
        }

        var existingGalleryImages = eventEntity.EventGalleryImages.ToList();
        
        var imagesToKeep = imageIds.ToHashSet();
        var imagesToRemove = existingGalleryImages
            .Where(egi => !imagesToKeep.Contains(egi.ImageId))
            .ToList();
        
        foreach (var galleryImage in imagesToRemove)
        {
            var image = await _context.Images.FindAsync(galleryImage.ImageId);
            if (image != null)
            {
                _context.Images.Remove(image);
            }
            _context.EventGalleryImages.Remove(galleryImage);
        }

        var imagesToReAdd = existingGalleryImages
            .Where(egi => imagesToKeep.Contains(egi.ImageId))
            .ToList();
        foreach (var galleryImage in imagesToReAdd)
        {
            _context.EventGalleryImages.Remove(galleryImage);
        }

        int order = 0;
        foreach (var imageId in imageIds)
        {
            var image = await _context.Images.FindAsync(imageId);
            if (image != null)
            {
                image.ImageType = ImageType.EventGallery;
                image.EventId = eventId;
                
                var now = DateTime.Now;
                var galleryImage = new EventGalleryImage
                {
                    EventId = eventId,
                    ImageId = imageId,
                    Order = order++,
                    CreatedAt = now,
                    UpdatedAt = now
                };
                _context.EventGalleryImages.Add(galleryImage);
            }
        }

        await _context.SaveChangesAsync();
    }
}