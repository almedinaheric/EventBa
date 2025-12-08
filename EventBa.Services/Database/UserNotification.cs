using EventBa.Model.Enums;

namespace EventBa.Services.Database;

public partial class UserNotification
{
    public Guid NotificationId { get; set; }
    public Guid UserId { get; set; }
    public NotificationStatus Status { get; set; }
    public virtual Notification Notification { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}

