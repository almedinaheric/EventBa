namespace EventBa.Model.Requests;

public class NotificationInsertRequestDto
{
    public Guid? UserId { get; set; }
    public string Title { get; set; } = null!;
    public string Content { get; set; } = null!;
    public bool IsImportant { get; set; }
    public bool IsSystemNotification { get; set; }
}