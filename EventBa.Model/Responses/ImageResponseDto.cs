namespace EventBa.Model.Responses;

public class ImageResponseDto
{
    public Guid Id { get; set; }
    public byte[]? Data { get; set; }
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}