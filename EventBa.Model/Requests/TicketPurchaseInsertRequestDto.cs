namespace EventBa.Model.Requests;

public class TicketPurchaseInsertRequestDto
{
    public Guid TicketId { get; set; }
    public Guid EventId { get; set; }
    public Guid UserId { get; set; }
    public string TicketCode { get; set; } = null!;
    public string QrVerificationHash { get; set; } = null!;
    public string QrData { get; set; } = null!;
    public byte[]? QrCodeImage { get; set; }
    public decimal PricePaid { get; set; } // Price paid at purchase time
}