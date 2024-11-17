using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class TicketRequest
{
    public TicketType TicketType { get; set; }
    public Guid? EventId { get; set; }
    public decimal? Price { get; set; }
    public int Quantity { get; set; }
}