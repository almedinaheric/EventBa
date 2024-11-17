namespace EventBa.Model.Requests;

public class SalesReportRequest
{
    public Guid? EventId { get; set; }
    public int? TicketsSold { get; set; }
    public decimal? TotalRevenue { get; set; }
    public int? AttendanceCount { get; set; }
}