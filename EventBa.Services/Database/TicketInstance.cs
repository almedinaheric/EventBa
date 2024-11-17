using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class TicketInstance
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid TicketInstanceId { get; set; }
    public Guid? TicketId { get; set; }
    public Guid? UserId { get; set; }
    public string? QrCode { get; set; }
    public string? Status { get; set; }
    public virtual Ticket? Ticket { get; set; }
    public virtual User? User { get; set; }
}
