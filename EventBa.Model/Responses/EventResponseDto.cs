using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class EventResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string Location { get; set; } = null!;
    public string? SocialMediaLinks { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public int Capacity { get; set; }
    public int CurrentAttendees { get; set; }
    public int AvailableTicketsCount { get; set; }
    public EventStatus Status { get; set; }
    public EventType Type { get; set; }
    public bool IsPublished { get; set; }
    public bool IsFeatured { get; set; }
    public bool IsPaid { get; set; }

    public CategoryResponseDto Category { get; set; } = null!;
    public ImageResponseDto? CoverImage { get; set; }
    public List<ImageResponseDto> GalleryImages { get; set; } = new();
    public Guid OrganizerId { get; set; }
}