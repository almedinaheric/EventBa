using EventBa.Model.Responses;
using EventBa.Model.Requests;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class EventReveiwController : BaseCRUDController<EventReviewResponseDto, EventReviewSearchObject,
    EventReviewInsertRequestDto, EventReviewUpdateRequestDto>
{
    private readonly IEventReviewService _eventReviewService;

    public EventReveiwController(
        ILogger<BaseCRUDController<EventReviewResponseDto, EventReviewSearchObject, EventReviewInsertRequestDto,
            EventReviewUpdateRequestDto>> logger, IEventReviewService service) : base(logger, service)
    {
        _eventReviewService = service;
    }
}