using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class UserNotification
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid UserNotificationId { get; set; }
    public Guid? NotificationId { get; set; }
    public Guid? UserId { get; set; }
    public string Status { get; set; } = null!;
    public virtual Notification? Notification { get; set; }
    public virtual User? User { get; set; }
}
