using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class TicketController : BaseCRUDController<TicketResponseDto, TicketSearchObject, TicketInsertRequestDto,
    TicketUpdateRequestDto>
{
    private readonly ITicketService _ticketService;

    public TicketController(ILogger<BaseCRUDController<TicketResponseDto, TicketSearchObject, TicketInsertRequestDto,
        TicketUpdateRequestDto>> logger, ITicketService service) : base(logger, service)
    {
        _ticketService = service;
    }
}