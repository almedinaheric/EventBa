namespace EventBa.Model.Responses;

public class SalesReportResponse
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid ReportId { get; set; }
    public Guid? EventId { get; set; }
    public int? TicketsSold { get; set; }
    public decimal? TotalRevenue { get; set; }
    public int? AttendanceCount { get; set; }
}