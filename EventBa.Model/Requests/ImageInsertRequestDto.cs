using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class ImageInsertRequestDto
{
    public string Data { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public ImageType? ImageType { get; set; }
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
}