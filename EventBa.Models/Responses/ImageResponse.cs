using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class ImageResponse
{
    public Guid ImageId { get; set; }
    public byte[] ImageData { get; set; } = null!;
    public ImageType ImageType { get; set; }
}
