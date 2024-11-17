namespace EventBa.Model.Requests;

public class EventRequest
{
    public string Name { get; set; } = null!;
    public Guid? CategoryId { get; set; }
    public string Type { get; set; } = null!;
    public string? Address { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? StartTime { get; set; }
    public TimeOnly? EndTime { get; set; }
    public string? Description { get; set; }
    public int? TicketsAvailable { get; set; }
    public Guid? OrganizerId { get; set; }
    public string Status { get; set; } = null!;
}
