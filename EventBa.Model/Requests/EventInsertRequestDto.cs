using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class EventInsertRequestDto
{
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string Location { get; set; } = null!;
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public int Capacity { get; set; }
    public int AvailableTicketsCount { get; set; }
    public EventStatus Status { get; set; } = EventStatus.Upcoming;
    public bool IsFeatured { get; set; }
    public EventType Type { get; set; }
    public bool IsPublished { get; set; }
    public bool IsPaid { get; set; }
    
    public Guid CategoryId { get; set; }
    public Guid? CoverImageId { get; set; }
}
