namespace EventBa.Model.Responses;

public class EventResponse
{
    public Guid EventId { get; set; }
    public string Name { get; set; } = null!;
    public Guid? CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string? Address { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? StartTime { get; set; }
    public TimeOnly? EndTime { get; set; }
    public string? Description { get; set; }
    public int? TicketsAvailable { get; set; }
    public Guid? OrganizerId { get; set; }
    public string OrganizerName { get; set; } = null!;
    public string Status { get; set; } = null!;
    public List<ImageResponse> Images { get; set; } = new List<ImageResponse>(); 
    public List<UserResponse> Users { get; set; } = new List<UserResponse>(); 
    public List<ReviewResponse> Reviews { get; set; } = new List<ReviewResponse>(); 
}