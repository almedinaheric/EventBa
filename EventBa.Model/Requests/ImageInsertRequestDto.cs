namespace EventBa.Model.Requests;

public class ImageInsertRequestDto
{
    public byte[] Data { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
}