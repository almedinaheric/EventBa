namespace EventBa.Model.Responses;

public class CategoryResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int EventCount { get; set; }
}