using System;
using System.Collections.Generic;
using EventBa.Services.Database.Enums;

namespace EventBa.Services.Database;

public partial class Ticket
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid TicketId { get; set; }
    public TicketType TicketType { get; set; }
    public Guid? EventId { get; set; }
    public decimal? Price { get; set; }
    public int Quantity { get; set; }
    public int? TicketsSold { get; set; }
    public virtual Event? Event { get; set; }
    public virtual ICollection<TicketInstance> TicketInstances { get; set; } = new List<TicketInstance>();
}