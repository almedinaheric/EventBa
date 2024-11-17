namespace EventBa.Services.Database;

public partial class SalesReport
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid ReportId { get; set; }
    public Guid? EventId { get; set; }
    public int? TicketsSold { get; set; }
    public decimal? TotalRevenue { get; set; }
    public int? AttendanceCount { get; set; }
    public virtual Event? Event { get; set; }
}