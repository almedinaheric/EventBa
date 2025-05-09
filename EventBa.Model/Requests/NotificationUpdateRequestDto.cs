namespace EventBa.Model.Requests;

public class NotificationUpdateRequestDto
{
    public Guid Id { get; set; }
    public bool IsRead { get; set; }
}