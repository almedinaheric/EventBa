namespace EventBa.Model.Requests;

public class CategoryInsertRequestDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}