using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class BasicEventResponseDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public EventStatus Status { get; set; }
    public ImageResponseDto? CoverImage { get; set; }
    
    //how to know paid vs free?
}