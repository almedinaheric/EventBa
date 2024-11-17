using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class TicketResponse
{
    public Guid TicketId { get; set; }
    public TicketType TicketType { get; set; }
    public Guid? EventId { get; set; }
    public decimal? Price { get; set; }
    public int Quantity { get; set; }
    public int? TicketsSold { get; set; }
}