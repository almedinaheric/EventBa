using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class EventReviewController : BaseCRUDController<EventReviewResponseDto, EventReviewSearchObject,
    EventReviewInsertRequestDto,
    EventReviewUpdateRequestDto>
{
    private readonly IEventReviewService _eventReviewService;

    public EventReviewController(
        ILogger<BaseCRUDController<EventReviewResponseDto, EventReviewSearchObject, EventReviewInsertRequestDto,
            EventReviewUpdateRequestDto>> logger, IEventReviewService service) : base(logger, service)
    {
        _eventReviewService = service;
    }

    [HttpGet("event/{eventId}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetReviewsForEvent(Guid eventId)
    {
        var reviews = await _eventReviewService.GetReviewsForEvent(eventId);
        return Ok(reviews);
    }

    [HttpGet("event/{eventId}/average-rating")]
    [AllowAnonymous]
    public async Task<IActionResult> GetAverageRatingForEvent(Guid eventId)
    {
        var averageRating = await _eventReviewService.GetAverageRatingForEvent(eventId);
        return Ok(new { AverageRating = averageRating });
    }
}