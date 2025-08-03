using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface IEventReviewService : ICRUDService<EventReviewResponseDto, EventReviewSearchObject, EventReviewInsertRequestDto,
    EventReviewUpdateRequestDto>
{
    Task<List<EventReviewResponseDto>> GetReviewsForEvent(Guid eventId);
    Task<double> GetAverageRatingForEvent(Guid eventId);
}