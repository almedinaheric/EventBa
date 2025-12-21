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
        
        // Store old cover image ID before mapping (since mapper will overwrite it)
        var oldCoverImageId = entity.CoverImageId;
        
        Console.WriteLine($"Updating event {id}: Old cover image ID = {oldCoverImageId}, New cover image ID = {update.CoverImageId}");
        
        // Map the update to the entity
        _mapper.Map(update, entity);
        
        // Handle cover image replacement - only delete old cover image if it's being replaced with a different one
        if (update.CoverImageId.HasValue && oldCoverImageId.HasValue && 
            update.CoverImageId.Value != oldCoverImageId.Value)
        {
            // Old cover image is being replaced with a new one, delete the old one
            Console.WriteLine($"Replacing cover image: deleting old image {oldCoverImageId.Value}");
            var oldCoverImage = await _context.Images.FindAsync(oldCoverImageId.Value);
            if (oldCoverImage != null)
            {
                _context.Images.Remove(oldCoverImage);
            }
        }
        else if (update.CoverImageId.HasValue && update.CoverImageId.Value == oldCoverImageId)
        {
            // Same cover image ID - no change needed, just keep it
            Console.WriteLine($"Cover image unchanged: keeping image {update.CoverImageId.Value}");
        }
        else if (!update.CoverImageId.HasValue && oldCoverImageId.HasValue)
        {
            // No cover image ID in update but one exists - preserve the existing one
            Console.WriteLine($"Preserving existing cover image: {oldCoverImageId.Value}");
            entity.CoverImageId = oldCoverImageId;
        }
        // If update.CoverImageId is null or same as old, we keep the existing cover image (don't delete it)
        
        await _context.SaveChangesAsync();
        
        // Reload the entity with all includes to ensure related entities are populated
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
        // Create the event first
        var result = await base.Insert(insert);
        
        // Reload the entity with all includes to ensure related entities are populated
        var entityWithIncludes = await AddInclude(_context.Set<Event>().Where(e => e.Id == Guid.Parse(result.Id.ToString())))
            .FirstOrDefaultAsync();
        
        if (entityWithIncludes != null)
        {
            result = _mapper.Map<EventResponseDto>(entityWithIncludes);
        }
        
        return result;
    }

    // Soft delete: Set IsPublished to false instead of actually deleting
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
        // Filter by type if specified
        if (search?.Type.HasValue == true)
        {
            query = query.Where(x => x.Type == search.Type.Value);
        }
        
        // Filter by search term if specified
        if (!string.IsNullOrWhiteSpace(search?.SearchTerm))
        {
            var searchTerm = search.SearchTerm.ToLower();
            query = query.Where(x => 
                x.Title.ToLower().Contains(searchTerm) || 
                (x.Description != null && x.Description.ToLower().Contains(searchTerm))
            );
        }
        
        // Only return published events (matching behavior of GetPublicEvents and GetPrivateEvents)
        query = query.Where(x => x.IsPublished);

        // Exclude current user's own events from search results
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
            // If user is not authenticated or can't be retrieved, continue without filtering
        }

        return query;
    }

    /*public override IQueryable<Event> AddFilter(IQueryable<Event> query, EventSearchObject? search = null)
    {
        if (search?.CategoryId.HasValue == true)
        {
            query = query.Where(x => x.CategoryId == search.CategoryId.Value);
        }

        if (search?.OrganizerId.HasValue == true)
        {
            query = query.Where(x => x.OrganizerId == search.OrganizerId.Value);
        }

        if (search?.EventStatus.HasValue == true)
        {
            query = query.Where(x => x.EventStatus == search.EventStatus.Value);
        }

        if (search?.EventType.HasValue == true)
        {
            query = query.Where(x => x.EventType == search.EventType.Value);
        }

        if (!string.IsNullOrEmpty(search?.Title))
        {
            query = query.Where(x => x.Title.Contains(search.Title));
        }

        if (search?.DateFrom.HasValue == true)
        {
            query = query.Where(x => x.EventDate >= search.DateFrom.Value);
        }

        if (search?.DateTo.HasValue == true)
        {
            query = query.Where(x => x.EventDate <= search.DateTo.Value);
        }

        if (search?.IsActive.HasValue == true)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }*/

    public async Task<List<EventResponseDto>> GetMyEvents()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var events = await _context.Events
            .Include(x => x.Category)
            .Include(x => x.CoverImage)
            .Include(x => x.EventGalleryImages)
            .ThenInclude(egi => egi.Image)
            .Where(x => x.OrganizerId == currentUser.Id)
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
        // Get current user to exclude their own events
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
            // If user is not authenticated, continue without filtering
        }

        var query = _context.Events
            .Where(e => e.Type == EventType.Public && e.IsPublished);
        
        // Exclude current user's own events
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
        // Get current user to exclude their own events
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
            // If user is not authenticated, continue without filtering
        }

        var query = _context.Events
            .Where(e => e.Type == EventType.Private && e.IsPublished);
        
        // Exclude current user's own events
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
        // Get current user to exclude their own events
        User? currentUser = null;
        try
        {
            currentUser = await _userService.GetUserEntityAsync();
        }
        catch
        {
            // If user is not authenticated, continue without filtering
        }

        var query = _context.Events
            .Where(e => e.Category.Id == categoryId && e.IsPublished);
        
        // Exclude current user's own events
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

        // Check if current user is the organizer or an admin
        var currentUser = await _userService.GetUserEntityAsync();
        
        // Load role if not already loaded
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

        // Check if event is past
        var eventEndDateTime = new DateTime(
            eventEntity.EndDate.Year,
            eventEntity.EndDate.Month,
            eventEntity.EndDate.Day,
            eventEntity.EndTime.Hour,
            eventEntity.EndTime.Minute,
            eventEntity.EndTime.Second
        );
        var isPast = eventEndDateTime < DateTime.Now;

        // If event is past, check if statistics exist, if not generate them
        if (isPast)
        {
            // Check if statistics already exist in database
            var existingStat = await _context.EventStatistics
                .FirstOrDefaultAsync(x => x.EventId == eventId);

            if (existingStat != null)
            {
                // Return existing statistics from database
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
                // Generate new statistics and save to database
                var soldTickets = eventEntity.Tickets.Sum(x => x.TicketPurchases.Count);
                var revenue = eventEntity.Tickets.Sum(x => x.TicketPurchases.Sum(p => p.PricePaid));
                var averageRating = eventEntity.EventReviews.Any() 
                    ? (double)eventEntity.EventReviews.Average(x => x.Rating) 
                    : 0.0;

                // Create new statistics record
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
            // For upcoming events, return current data without saving to statistics table
            var soldTickets = eventEntity.Tickets.Sum(x => x.TicketPurchases.Count);
            var revenue = eventEntity.Tickets.Sum(x => x.TicketPurchases.Sum(p => p.PricePaid));
            var averageRating = 0.0; // No ratings for upcoming events

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
        Console.WriteLine($"AddGalleryImages called for event {eventId} with {imageIds.Count} images");
        
        var eventEntity = await _context.Events.FindAsync(eventId);
        if (eventEntity == null)
        {
            Console.WriteLine($"Event {eventId} not found!");
            throw new UserException("Event not found");
        }

        Console.WriteLine($"Event {eventId} found, processing images...");
        
        int order = 0;
        foreach (var imageId in imageIds)
        {
            Console.WriteLine($"Processing image {imageId}...");
            var image = await _context.Images.FindAsync(imageId);
            if (image != null)
            {
                Console.WriteLine($"Image {imageId} found, setting type to EventGallery");
                image.ImageType = ImageType.EventGallery;
                image.EventId = eventId;
                
                // Check if gallery image link already exists
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
                    Console.WriteLine($"Created EventGalleryImage link for image {imageId} with order {order - 1}");
                }
                else
                {
                    Console.WriteLine($"EventGalleryImage link already exists for image {imageId}");
                }
            }
            else
            {
                Console.WriteLine($"Image {imageId} not found in database!");
            }
        }

        await _context.SaveChangesAsync();
        Console.WriteLine($"Gallery images saved successfully for event {eventId}");
    }

    public async Task ReplaceGalleryImages(Guid eventId, List<Guid> imageIds)
    {
        Console.WriteLine($"ReplaceGalleryImages called for event {eventId} with {imageIds.Count} images");
        
        var eventEntity = await _context.Events
            .Include(e => e.EventGalleryImages)
            .FirstOrDefaultAsync(e => e.Id == eventId);
            
        if (eventEntity == null)
        {
            throw new UserException("Event not found");
        }

        // Get existing gallery images
        var existingGalleryImages = eventEntity.EventGalleryImages.ToList();
        
        // Find images that are being removed (not in the new list)
        var imagesToKeep = imageIds.ToHashSet();
        var imagesToRemove = existingGalleryImages
            .Where(egi => !imagesToKeep.Contains(egi.ImageId))
            .ToList();
        
        // Delete only the gallery images and Image records that are being removed
        foreach (var galleryImage in imagesToRemove)
        {
            var image = await _context.Images.FindAsync(galleryImage.ImageId);
            if (image != null)
            {
                _context.Images.Remove(image);
            }
            _context.EventGalleryImages.Remove(galleryImage);
        }

        // Remove existing links for images that are being kept (we'll re-add them with correct order)
        var imagesToReAdd = existingGalleryImages
            .Where(egi => imagesToKeep.Contains(egi.ImageId))
            .ToList();
        foreach (var galleryImage in imagesToReAdd)
        {
            _context.EventGalleryImages.Remove(galleryImage);
        }

        // Add all gallery images (both new and existing) with correct order
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
                Console.WriteLine($"Added gallery image {imageId} at order {order - 1}");
            }
            else
            {
                Console.WriteLine($"Warning: Image with ID {imageId} not found in database, skipping");
            }
        }
        
        Console.WriteLine($"Total gallery images after update: {order}");

        await _context.SaveChangesAsync();
        Console.WriteLine($"Gallery images replaced successfully for event {eventId}");
    }
}