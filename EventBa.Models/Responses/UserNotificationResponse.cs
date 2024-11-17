namespace EventBa.Model.Responses;

public class UserNotificationResponse
{
    public Guid UserNotificationId { get; set; }
    public Guid? NotificationId { get; set; }
    public Guid? UserId { get; set; }
    public string Status { get; set; } = null!;
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
}