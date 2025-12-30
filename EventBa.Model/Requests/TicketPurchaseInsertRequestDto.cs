namespace EventBa.Model.Requests;

public class TicketPurchaseInsertRequestDto
{
    public Guid TicketId { get; set; }
    public Guid EventId { get; set; }
    public Guid? UserId { get; set; }
    public string? TicketCode { get; set; }
    public string? QrVerificationHash { get; set; }
    public string? QrData { get; set; }
    public byte[]? QrCodeImage { get; set; }
    public decimal? PricePaid { get; set; }
}