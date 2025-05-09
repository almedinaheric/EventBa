using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface ITicketService : ICRUDService<TicketResponseDto, TicketSearchObject, TicketInsertRequestDto,
    TicketUpdateRequestDto>
{
}