using System;
using System.Collections.Generic;
using EventBa.Models.Enums;

namespace EventBa.Services.Database;

public partial class Notification
{
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }

    public Guid? EventId { get; set; }

    public bool IsSystemNotification { get; set; }

    public string Title { get; set; } = null!;

    public string Content { get; set; } = null!;

    public bool IsImportant { get; set; }

    public NotificationStatus Status { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Event? Event { get; set; }

    public virtual User? User { get; set; }
}
