namespace EventBa.Model.Requests;

public class TicketInstanceRequest
{
    public Guid? TicketId { get; set; }
    public Guid? UserId { get; set; }
    public string? QrCode { get; set; }
    public string? Status { get; set; }
}