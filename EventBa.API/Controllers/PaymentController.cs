using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace EventBa.API.Controllers;

[ApiController]
public class PaymentController : BaseCRUDController<PaymentResponseDto, PaymentSearchObject, PaymentInsertRequestDto,
    PaymentUpdateRequestDto>
{
    private readonly IPaymentService _paymentService;
    private readonly IConfiguration _configuration;

    public PaymentController(
        ILogger<BaseCRUDController<PaymentResponseDto, PaymentSearchObject, PaymentInsertRequestDto,
            PaymentUpdateRequestDto>> logger, IPaymentService service, IConfiguration configuration) : base(logger,
        service)
    {
        _paymentService = service;
        _configuration = configuration;
    }

    [HttpGet("my-payments")]
    [Authorize]
    public async Task<IActionResult> GetMyPayments()
    {
        var payments = await _paymentService.GetMyPayments();
        return Ok(payments);
    }

    [HttpPost("create-payment-intent")]
    [Authorize]
    public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequestDto request)
    {
        try
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(request.Amount * 100),
                Currency = request.Currency.ToLower(),
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string>
                {
                    { "ticketId", request.TicketId },
                    { "eventId", request.EventId },
                    { "quantity", request.Quantity.ToString() }
                }
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            return Ok(new
            {
                clientSecret = paymentIntent.ClientSecret,
                publishableKey = _configuration["Stripe:PublishableKey"]
            });
        }
        catch (StripeException e)
        {
            return BadRequest(new { error = e.Message });
        }
    }
}