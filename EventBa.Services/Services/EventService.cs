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

public class EventService : BaseCRUDService<EventResponseDto, Event, EventSearchObject,
    EventInsertRequestDto, EventUpdateRequestDto>, IEventService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    
    private readonly IUserService _userService;

    public EventService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }
    
    public override async Task BeforeInsert(Event entity, EventInsertRequestDto insert)
    {
        entity.Organizer = await _userService.GetUserEntityAsync();
    }

    public override IQueryable<Event> AddInclude(IQueryable<Event> query, EventSearchObject? search = null)
    {
        query = query.Include(x => x.Organizer)
                    .Include(x => x.Category)
                    .Include(x => x.EventGalleryImages)
                    .Include(x => x.EventReviews)
                    .Include(x => x.Tickets);

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
            .Include(x => x.EventGalleryImages)
            .Where(x => x.OrganizerId == currentUser.Id)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(events);
    }
    
    public async Task<List<EventResponseDto>> GetEventsByOrganizer(Guid organizerId)
    {
        var events = await _context.Events
            .Include(x => x.Category)
            .Include(x => x.EventGalleryImages)
            .Include(x => x.EventReviews)
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
            .Include(x => x.EventReviews)
            .Include(x => x.Tickets)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (entity == null)
            throw new UserException("Event not found");

        return _mapper.Map<EventResponseDto>(entity);
    }
    public async Task<List<EventResponseDto>> GetRecommendedEvents()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var recommendedEvents = await _context.RecommendedEvents
            .Include(x => x.Event)
            .ThenInclude(x => x.Category)
            .Include(x => x.Event)
            .ThenInclude(x => x.EventGalleryImages)
            .Where(x => x.UserId == currentUser.Id)
            .Select(x => x.Event)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(recommendedEvents);
    }
    
    public async Task<List<EventResponseDto>> GetPublicEvents()
    {
        var publicEvents = await _context.Events
            .Where(e => e.Type == EventType.Public && e.IsPublished)
            .Include(e => e.Category)
            .Include(e => e.EventGalleryImages)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(publicEvents);
    }

    public async Task<List<EventResponseDto>> GetPrivateEvents()
    {
        var privateEvents = await _context.Events
            .Where(e => e.Type == EventType.Private && e.IsPublished)
            .Include(e => e.Category)
            .Include(e => e.EventGalleryImages)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(privateEvents);
    }

    public async Task<List<EventResponseDto>> GetEventsByCategoryId(Guid categoryId)
    {
        var privateEvents = await _context.Events
            .Where(e => e.Category.Id == categoryId && e.IsPublished)
            .Include(e => e.Category)
            .Include(e => e.EventGalleryImages)
            .ToListAsync();

        return _mapper.Map<List<EventResponseDto>>(privateEvents);
    }
    
    public async Task<List<EventResponseDto>> GetUserFavoriteEventsAsync()
    {
        var currentUser = await _userService.GetUserAsync();

        var user = await _context.Users
            .Include(u => u.FavoriteEvents)
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
            .FirstOrDefaultAsync(x => x.Id == eventId);

        if (eventEntity == null)
            return null;

        var totalTickets = eventEntity.Tickets.Sum(x => x.Quantity);
        var soldTickets = eventEntity.Tickets.Sum(x => x.TicketPurchases.Count);
        var revenue = eventEntity.Tickets.Sum(x => x.TicketPurchases.Sum(p => p.Ticket.Price));

        return new EventStatisticsResponseDto
        {
            EventId = eventId,
            TotalTicketsSold = soldTickets,
            //SoldTickets = soldTickets,
            TotalRevenue = revenue,
            //SoldPercentage = totalTickets > 0 ? (double)soldTickets / totalTickets * 100 : 0
        };
    }
}