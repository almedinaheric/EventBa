using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface ITicketPurchaseService : ICRUDService<TicketPurchaseResponseDto, TicketPurchaseSearchObject,
    TicketPurchaseInsertRequestDto, TicketPurchaseUpdateRequestDto>
{
    Task<List<TicketPurchaseResponseDto>> GetMyPurchases();
}