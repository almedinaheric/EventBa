using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

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
}