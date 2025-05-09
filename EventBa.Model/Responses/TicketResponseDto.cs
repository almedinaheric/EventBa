namespace EventBa.Model.Responses;

public class TicketResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid EventId { get; set; }
    public string TicketType { get; set; } = null!;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public int QuantityAvailable { get; set; }
    public int QuantitySold { get; set; }
    public DateTime SaleStartDate { get; set; }
    public DateTime SaleEndDate { get; set; }
}