using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class Notification
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid NotificationId { get; set; }
    public string Title { get; set; } = null!;
    public string Content { get; set; } = null!;
    public string Status { get; set; } = null!;
    public Guid? SenderId { get; set; }
    public virtual User? Sender { get; set; }
    public virtual ICollection<UserNotification> UserNotifications { get; set; } = new List<UserNotification>();
}
