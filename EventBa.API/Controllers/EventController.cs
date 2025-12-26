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
    private readonly IRecommendedEventService _recommendedEventService;

    public EventController(ILogger<BaseCRUDController<EventResponseDto, EventSearchObject, EventInsertRequestDto,
        EventUpdateRequestDto>> logger, IEventService service, IRecommendedEventService recommendedEventService) : base(logger, service)
    {
        _eventService = service;
        _recommendedEventService = recommendedEventService;
    }


    [HttpGet("my-events")]
    [Authorize]
    public async Task<IActionResult> GetMyEvents()
    {
        var events = await _eventService.GetMyEvents();
        return Ok(events);
    }

    [HttpGet("my-events-count")]
    [Authorize]
    public async Task<IActionResult> GetMyEventsCount()
    {
        var events = await _eventService.GetMyEvents();
        return Ok(new { count = events.Count });
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
    [Authorize]
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

    [HttpPost("train-recommendation-model")]
    [Authorize(Roles = "Admin")]
    public IActionResult TrainRecommendationModel()
    {
        try
        {
            _recommendedEventService.TrainModel();
            return Ok(new { message = "Recommendation model trained successfully" });
        }
        catch (Exception ex)
        {
            // ErrorFilter will handle this, but we can add more context
            return StatusCode(500, new { message = $"Failed to train model: {ex.Message}" });
        }
    }

    [HttpPost("retrain-recommendation-model")]
    [Authorize(Roles = "Admin")]
    public IActionResult RetrainRecommendationModel()
    {
        try
        {
            _recommendedEventService.RetrainModel();
            return Ok(new { message = "Recommendation model retrained successfully" });
        }
        catch (Exception ex)
        {
            // ErrorFilter will handle this, but we can add more context
            return StatusCode(500, new { message = $"Failed to retrain model: {ex.Message}" });
        }
    }

    [HttpDelete("delete-recommendations")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteRecommendations()
    {
        await _recommendedEventService.DeleteAllRecommendations();
        return Ok(new { message = "All recommendations deleted successfully" });
    }

    [HttpPost("{eventId}/gallery-images")]
    [Authorize]
    public async Task<IActionResult> AddGalleryImages(Guid eventId, [FromBody] List<Guid> imageIds)
    {
        await _eventService.AddGalleryImages(eventId, imageIds);
        return Ok(new { message = "Gallery images added successfully" });
    }

    [HttpPut("{eventId}/gallery-images")]
    [Authorize]
    public async Task<IActionResult> ReplaceGalleryImages(Guid eventId, [FromBody] List<Guid> imageIds)
    {
        await _eventService.ReplaceGalleryImages(eventId, imageIds);
        return Ok(new { message = "Gallery images replaced successfully" });
    }
}