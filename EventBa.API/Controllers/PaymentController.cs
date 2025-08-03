using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class PaymentController : BaseCRUDController<PaymentResponseDto, PaymentSearchObject, PaymentInsertRequestDto,
    PaymentUpdateRequestDto>
{
    private readonly IPaymentService _paymentService;

    public PaymentController(ILogger<BaseCRUDController<PaymentResponseDto, PaymentSearchObject, PaymentInsertRequestDto,
        PaymentUpdateRequestDto>> logger, IPaymentService service) : base(logger, service)
    {
        _paymentService = service;
    }

    [HttpGet("my-payments")]
    [Authorize]
    public async Task<IActionResult> GetMyPayments()
    {
        var payments = await _paymentService.GetMyPayments();
        return Ok(payments);
    }
} 