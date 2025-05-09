namespace EventBa.Model.Responses;

public class NotificationResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid UserId { get; set; }
    public string Message { get; set; } = null!;
    public bool IsRead { get; set; }
}