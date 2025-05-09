using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services;

public class EventReviewService : BaseCRUDService<EventReviewResponseDto, EventReview, EventReviewSearchObject,
    EventReviewInsertRequestDto, EventReviewUpdateRequestDto>, IEventReviewService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }

    public EventReviewService(EventBaDbContext context, IMapper mapper) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
    }
}