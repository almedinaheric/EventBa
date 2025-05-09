using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class RoleResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Name { get; set; } = null!;
}