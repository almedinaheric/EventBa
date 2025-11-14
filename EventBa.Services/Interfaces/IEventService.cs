using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface IEventService : ICRUDService<EventResponseDto, EventSearchObject, EventInsertRequestDto,
    EventUpdateRequestDto>
{
    Task<List<EventResponseDto>> GetMyEvents();
    
    Task<List<EventResponseDto>> GetEventsByOrganizer(Guid userId);

    Task<List<EventResponseDto>> GetRecommendedEvents();
    Task<List<EventResponseDto>> GetPublicEvents();
    Task<List<EventResponseDto>> GetPrivateEvents();
    Task<List<EventResponseDto>> GetEventsByCategoryId(Guid categoryId);
    Task<EventStatisticsResponseDto> GetEventStatistics(Guid eventId);
    Task<List<EventResponseDto>> GetUserFavoriteEventsAsync();
    Task<bool> ToggleFavoriteEventAsync(Guid eventId);
    Task<EventResponseDto> GetById(Guid id);
    Task AddGalleryImages(Guid eventId, List<Guid> imageIds);
}