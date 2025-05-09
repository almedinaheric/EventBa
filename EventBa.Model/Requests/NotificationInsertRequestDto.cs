namespace EventBa.Model.Requests;

public class NotificationInsertRequestDto
{
    public Guid UserId { get; set; }
    public string Message { get; set; } = null!;
}