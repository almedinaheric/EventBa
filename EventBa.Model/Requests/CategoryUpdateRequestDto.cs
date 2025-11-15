namespace EventBa.Model.Requests;

public class CategoryUpdateRequestDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}