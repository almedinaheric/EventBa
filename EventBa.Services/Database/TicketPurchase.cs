namespace EventBa.Services.Database;

public partial class TicketPurchase
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid TicketId { get; set; }
    public Guid EventId { get; set; }
    public Guid UserId { get; set; }
    public string QrVerificationHash { get; set; } = null!;
    public string QrData { get; set; } = null!;
    public byte[]? QrCodeImage { get; set; }
    public string TicketCode { get; set; } = null!;
    public bool IsUsed { get; set; }
    public DateTime? UsedAt { get; set; }
    public bool IsValid { get; set; }
    public DateTime? InvalidatedAt { get; set; }
    public virtual Event Event { get; set; } = null!;
    public virtual Ticket Ticket { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}
