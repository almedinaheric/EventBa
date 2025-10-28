using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class BasicEventResponseDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public EventStatus Status { get; set; }
    public string Location { get; set; } = null!;
    public ImageResponseDto? CoverImage { get; set; }
    public bool IsPaid { get; set; }
}