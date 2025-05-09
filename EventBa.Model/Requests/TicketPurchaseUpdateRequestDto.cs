namespace EventBa.Model.Requests;

public class TicketPurchaseUpdateRequestDto
{
    public Guid Id { get; set; }
    public bool IsUsed { get; set; }
    public DateTime? UsedAt { get; set; }
    public bool IsValid { get; set; }
    public DateTime? InvalidatedAt { get; set; }
}