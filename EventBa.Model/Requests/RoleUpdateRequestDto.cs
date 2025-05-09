namespace EventBa.Model.Requests;

public class RoleUpdateRequestDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
}