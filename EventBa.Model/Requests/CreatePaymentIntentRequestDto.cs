namespace EventBa.Model.Requests;

public class CreatePaymentIntentRequestDto
{
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string TicketId { get; set; } = string.Empty;
    public string EventId { get; set; } = string.Empty;
    public int Quantity { get; set; }
}