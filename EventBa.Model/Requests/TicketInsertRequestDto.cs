namespace EventBa.Model.Requests;

public class TicketInsertRequestDto
{
    public Guid EventId { get; set; }
    public string TicketType { get; set; } = null!;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public DateTime SaleStartDate { get; set; }
    public DateTime SaleEndDate { get; set; }
}