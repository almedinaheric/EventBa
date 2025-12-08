using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class PaymentInsertRequestDto
{
    // UserId is set automatically from the authenticated user
    public Guid? UserId { get; set; }
    public Guid EventId { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    // Status defaults to Completed for successful payments, set in BeforeInsert if not provided
    public PaymentStatus? Status { get; set; }
}