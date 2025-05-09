using EventBa.Model.Enums;

namespace EventBa.Services.Database;

public partial class Ticket
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid EventId { get; set; }
    public TicketType TicketType { get; set; }
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public int QuantityAvailable { get; set; }
    public int QuantitySold { get; set; }
    public DateTime SaleStartDate { get; set; }
    public DateTime SaleEndDate { get; set; }
    public virtual Event Event { get; set; } = null!;
    public virtual ICollection<TicketPurchase> TicketPurchases { get; set; } = new List<TicketPurchase>();
}
