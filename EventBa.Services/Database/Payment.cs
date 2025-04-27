using System;
using System.Collections.Generic;
using EventBa.Models.Enums;

namespace EventBa.Services.Database;

public partial class Payment
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid EventId { get; set; }

    public decimal Amount { get; set; }

    public string Currency { get; set; } = null!;
    
    public PaymentStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Event Event { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
