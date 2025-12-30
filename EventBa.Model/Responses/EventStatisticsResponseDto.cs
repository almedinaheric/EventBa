namespace EventBa.Model.Responses;

public class EventStatisticsResponseDto
{
    public Guid EventId { get; set; }
    public int TotalTicketsSold { get; set; }
    public decimal TotalRevenue { get; set; }
    public int CurrentAttendees { get; set; }
    public double AverageRating { get; set; }
}