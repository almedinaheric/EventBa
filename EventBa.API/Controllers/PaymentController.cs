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
            var secretKey = _configuration["Stripe:SecretKey"];
            var publishableKey = _configuration["Stripe:PublishableKey"];

            if (string.IsNullOrEmpty(secretKey))
            {
                _logger.LogError("Stripe SecretKey is not configured");
                return BadRequest(new { error = "Stripe SecretKey is not configured" });
            }

            if (string.IsNullOrEmpty(publishableKey))
            {
                _logger.LogError("Stripe PublishableKey is not configured");
                return BadRequest(new { error = "Stripe PublishableKey is not configured" });
            }

            if (StripeConfiguration.ApiKey != secretKey)
            {
                _logger.LogWarning("StripeConfiguration.ApiKey doesn't match config. Updating...");
                StripeConfiguration.ApiKey = secretKey;
            }

            if (!secretKey.StartsWith("sk_test_") && !secretKey.StartsWith("sk_live_"))
            {
                _logger.LogError("Invalid Stripe SecretKey format: {Key}", secretKey.Substring(0, Math.Min(20, secretKey.Length)));
                return BadRequest(new { error = "Invalid Stripe SecretKey format" });
            }

            if (!publishableKey.StartsWith("pk_test_") && !publishableKey.StartsWith("pk_live_"))
            {
                _logger.LogError("Invalid Stripe PublishableKey format: {Key}", publishableKey.Substring(0, Math.Min(20, publishableKey.Length)));
                return BadRequest(new { error = "Invalid Stripe PublishableKey format" });
            }

            if (StripeConfiguration.ApiKey != secretKey)
            {
                _logger.LogWarning("StripeConfiguration.ApiKey mismatch. Updating to match config...");
                StripeConfiguration.ApiKey = secretKey;
            }

            _logger.LogInformation("Creating PaymentIntent with amount: {Amount}, currency: {Currency}", request.Amount, request.Currency);

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
                publishableKey = publishableKey
            });
        }
        catch (StripeException e)
        {
            _logger.LogError(e, "Stripe error creating payment intent: {Message}", e.Message);
            return BadRequest(new { error = e.Message, type = e.StripeError?.Type, code = e.StripeError?.Code });
        }
        catch (Exception e)
        {
            _logger.LogError(e, "Error creating payment intent: {Message}", e.Message);
            return StatusCode(500, new { error = "Internal server error while creating payment intent" });
        }
    }
}