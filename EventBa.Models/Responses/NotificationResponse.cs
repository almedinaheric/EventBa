namespace EventBa.Model.Responses;

public class NotificationResponse
{
    public Guid NotificationId { get; set; }
    public string Title { get; set; } = null!;
    public string Content { get; set; } = null!;
    public string Status { get; set; } = null!;
    public Guid? SenderId { get; set; }
    public string? SenderName { get; set; }
}