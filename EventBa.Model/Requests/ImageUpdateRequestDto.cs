namespace EventBa.Model.Requests;

public class ImageUpdateRequestDto
{
    public Guid Id { get; set; }
    public string Data { get; set; } = null!;
    public string ContentType { get; set; } = null!;
}