using EventBa.Model.Enums;

namespace EventBa.Model.Requests;

public class ImageRequest
{
    public byte[] ImageData { get; set; } = null!;
    public ImageType ImageType { get; set; }
    public Guid? EventId { get; set; }
}
