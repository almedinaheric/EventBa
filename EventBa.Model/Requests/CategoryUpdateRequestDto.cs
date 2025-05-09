namespace EventBa.Model.Requests;

public class CategoryUpdateRequestDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}