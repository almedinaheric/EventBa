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


    [HttpGet("my-events")]
    [Authorize]
    public async Task<IActionResult> GetMyEvents()
    {
        var events = await _eventService.GetMyEvents();
        return Ok(events);
    }
    
    [HttpGet("organizer/{organizerId}")]
    public async Task<ActionResult<List<EventResponseDto>>> GetEventsByOrganizer(Guid organizerId)
    {
        var events = await _eventService.GetEventsByOrganizer(organizerId);
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
    
    [HttpGet("favorites")]
    [Authorize]
    public async Task<IActionResult> GetFavoriteEvents()
    {
        var result = await _eventService.GetUserFavoriteEventsAsync();
        return Ok(result);
    }

    [HttpPost("{id}/favorite-toggle")]
    [Authorize]
    public async Task<IActionResult> ToggleFavorite(Guid id)
    {
        var result = await _eventService.ToggleFavoriteEventAsync(id);
        return Ok(result);
    }
}