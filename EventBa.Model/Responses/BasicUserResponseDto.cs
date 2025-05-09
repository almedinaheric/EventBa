namespace EventBa.Model.Responses;

public class BasicUserResponseDto
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = null!;
    public ImageResponseDto? ProfileImage { get; set; }
}