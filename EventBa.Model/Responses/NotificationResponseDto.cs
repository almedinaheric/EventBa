using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class NotificationResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
    public bool IsSystemNotification { get; set; }
    public string Title { get; set; } = null!;
    public string Content { get; set; } = null!;
    public bool IsImportant { get; set; }
    public NotificationStatus Status { get; set; }
    public bool IsRead => Status == NotificationStatus.Read;
}