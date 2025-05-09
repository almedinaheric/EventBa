using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class TicketPurchaseController : BaseCRUDController<TicketPurchaseResponseDto, TicketPurchaseSearchObject, TicketPurchaseInsertRequestDto,
    TicketPurchaseUpdateRequestDto>
{
    private readonly ITicketPurchaseService _ticketPurchaseService;

    public TicketPurchaseController(ILogger<BaseCRUDController<TicketPurchaseResponseDto, TicketPurchaseSearchObject, TicketPurchaseInsertRequestDto,
        TicketPurchaseUpdateRequestDto>> logger, ITicketPurchaseService service) : base(logger, service)
    {
        _ticketPurchaseService = service;
    }
}