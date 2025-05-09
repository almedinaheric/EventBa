using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface IEventReviewService : ICRUDService<EventReviewResponseDto, EventReviewSearchObject,
    EventReviewInsertRequestDto, EventReviewUpdateRequestDto>
{
}