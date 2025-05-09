namespace EventBa.Model.Requests;

public class ImageUpdateRequestDto
{
    public Guid Id { get; set; }
    public byte[] Data { get; set; } = null!;
    public string ContentType { get; set; } = null!;
}