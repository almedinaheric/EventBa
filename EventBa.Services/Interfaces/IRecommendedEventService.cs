using EventBa.Model.Responses;

namespace EventBa.Services.Interfaces;

public interface IRecommendedEventService
{
    void TrainModel();
    void RetrainModel();
    Task<List<EventResponseDto>> GetRecommendedEventsForUser(Guid userId);
    Task DeleteAllRecommendations();
    Task DeleteRecommendationsForUser(Guid userId);
}

