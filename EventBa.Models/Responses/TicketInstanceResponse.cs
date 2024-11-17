namespace EventBa.Model.Responses;

public class TicketInstanceResponse
{
    public Guid TicketInstanceId { get; set; }
    public Guid? TicketId { get; set; }
    public Guid? UserId { get; set; }
    public string? QrCode { get; set; }
    public string? Status { get; set; }
}