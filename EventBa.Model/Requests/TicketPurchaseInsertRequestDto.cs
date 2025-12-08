namespace EventBa.Model.Requests;

public class TicketPurchaseInsertRequestDto
{
    public Guid TicketId { get; set; }
    public Guid EventId { get; set; }
    // UserId is set automatically from the authenticated user
    public Guid? UserId { get; set; }
    // These fields are auto-generated in BeforeInsert, so they're optional in the DTO
    public string? TicketCode { get; set; }
    public string? QrVerificationHash { get; set; }
    public string? QrData { get; set; }
    public byte[]? QrCodeImage { get; set; }
    // PricePaid is set automatically from the ticket price
    public decimal? PricePaid { get; set; }
}