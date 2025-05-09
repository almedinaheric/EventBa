namespace EventBa.Model.Requests;

public class EventReviewUpdateRequestDto
{
    public Guid Id { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}