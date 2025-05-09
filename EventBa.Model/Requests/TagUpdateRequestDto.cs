namespace EventBa.Model.Requests;

public class TagInsertRequestDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
}