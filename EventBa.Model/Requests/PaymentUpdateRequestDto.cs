using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class PaymentUpdateRequestDto
{
    public Guid Id { get; set; }
    public PaymentStatus Status { get; set; }
}