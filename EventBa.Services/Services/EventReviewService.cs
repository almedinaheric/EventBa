using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class EventReviewService : BaseCRUDService<EventReviewResponseDto, EventReview, EventReviewSearchObject,
    EventReviewInsertRequestDto, EventReviewUpdateRequestDto>, IEventReviewService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public EventReviewService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(EventReview entity, EventReviewInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
    }

    public override IQueryable<EventReview> AddInclude(IQueryable<EventReview> query, EventReviewSearchObject? search = null)
    {
        query = query.Include(x => x.User)
                    .Include(x => x.Event);
        return query;
    }
    
    public async Task<List<EventReviewResponseDto>> GetReviewsForEvent(Guid eventId)
    {
        var reviews = await _context.EventReviews
            .Include(x => x.User)
            .Where(x => x.EventId == eventId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<EventReviewResponseDto>>(reviews);
    }

    public async Task<double> GetAverageRatingForEvent(Guid eventId)
    {
        var averageRating = await _context.EventReviews
            .Where(x => x.EventId == eventId)
            .AverageAsync(x => x.Rating);

        return averageRating;
    }
}