namespace EventBa.Model.Requests;

public class ReviewRequest
{
    public Guid? EventId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}