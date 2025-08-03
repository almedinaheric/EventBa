using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
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

    [HttpGet]
    [AllowAnonymous]
    public override async Task<PagedResult<EventResponseDto>> Get([FromQuery] EventSearchObject search)
    {
        return await _service.Get(search);
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public override async Task<EventResponseDto> GetById(Guid id)
    {
        return await _service.GetById(id);
    }

    [HttpGet("my-events")]
    [Authorize]
    public async Task<IActionResult> GetMyEvents()
    {
        var events = await _eventService.GetMyEvents();
        return Ok(events);
    }

    [HttpGet("recommended")]
    [Authorize]
    public async Task<IActionResult> GetRecommendedEvents()
    {
        var events = await _eventService.GetRecommendedEvents();
        return Ok(events);
    }
    
    [HttpGet("public")]
    [Authorize]
    public async Task<IActionResult> GetPublicEvents()
    {
        var events = await _eventService.GetPublicEvents();
        return Ok(events);
    }
    
    [HttpGet("private")]
    [Authorize]
    public async Task<IActionResult> GetPrivateEvents()
    {
        var events = await _eventService.GetPrivateEvents();
        return Ok(events);
    }
    
    [HttpGet("category/{categoryId}")]
    [Authorize]
    public async Task<IActionResult> GetEventsByCategoryId(Guid categoryId)
    {
        var events = await _eventService.GetEventsByCategoryId(categoryId);
        return Ok(events);
    }

    [HttpGet("{id}/statistics")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetEventStatistics(Guid id)
    {
        var statistics = await _eventService.GetEventStatistics(id);
        return Ok(statistics);
    }
}