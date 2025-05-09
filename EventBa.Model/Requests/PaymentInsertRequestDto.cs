using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class PaymentInsertRequestDto
{
    public Guid UserId { get; set; }
    public Guid EventId { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = null!;
    public PaymentStatus Status { get; set; }
    public DateTime PaymentDate { get; set; }
    public string PaymentMethod { get; set; } = null!;
}