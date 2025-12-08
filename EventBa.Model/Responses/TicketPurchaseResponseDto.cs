namespace EventBa.Model.Responses;

public class TicketPurchaseResponseDto
{
    public Guid Id { get; set; }
    public Guid TicketId { get; set; }
    public Guid EventId { get; set; }
    public Guid UserId { get; set; }
    public string QrVerificationHash { get; set; }
    public string QrData { get; set; }
    public byte[]? QrCodeImage { get; set; }
    public string TicketCode { get; set; }
    public bool IsUsed { get; set; }
    public DateTime? UsedAt { get; set; }
    public bool IsValid { get; set; }
    public DateTime? InvalidatedAt { get; set; }
    public decimal PricePaid { get; set; } // Price paid at purchase time
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}