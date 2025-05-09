using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class EventController : BaseCRUDController<EventResponseDto, EventSearchObject, EventInsertRequestDto,
    EventUpdateRequestDto>
{
    private readonly IEventService _eventService;

    public EventController(ILogger<BaseCRUDController<EventResponseDto, EventSearchObject, EventInsertRequestDto,
        EventUpdateRequestDto>> logger, IEventService service) : base(logger, service)
    {
        _eventService = service;
    }
    
    public override Task<EventResponseDto> Insert(EventInsertRequestDto insert)
    {
        return base.Insert(insert);
    }
}