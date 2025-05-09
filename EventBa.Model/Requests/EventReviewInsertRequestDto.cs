namespace EventBa.Model.Requests;

public class EventReviewInsertRequestDto
{
    public Guid EventId { get; set; }
    public Guid UserId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}