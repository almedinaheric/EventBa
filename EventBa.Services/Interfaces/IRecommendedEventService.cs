using EventBa.Model.Responses;

namespace EventBa.Services.Interfaces;

public interface IRecommendedEventService
{
    void TrainModel();
    Task<List<EventResponseDto>> GetRecommendedEventsForUser(Guid userId);
    Task DeleteAllRecommendations();
}

