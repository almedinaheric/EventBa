using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
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

    [HttpGet("my-purchases")]
    [Authorize]
    public async Task<IActionResult> GetMyPurchases()
    {
        var purchases = await _ticketPurchaseService.GetMyPurchases();
        return Ok(purchases);
    }

    [HttpPost("validate/{eventId}")]
    [Authorize]
    public async Task<IActionResult> ValidateTicket([FromRoute] Guid eventId, [FromBody] ValidateTicketRequest request)
    {
        try
        {
            var result = await _ticketPurchaseService.ValidateTicket(request.TicketCode, eventId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}

public class ValidateTicketRequest
{
    public string TicketCode { get; set; } = null!;
}