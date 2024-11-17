namespace EventBa.Model.Requests;

public class UserNotificationRequest
{
    public Guid? NotificationId { get; set; }
    public string Status { get; set; } = null!;
}