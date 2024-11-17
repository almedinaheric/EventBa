namespace EventBa.Model.Requests;

public class UserRequest
{
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public Guid? RoleId { get; set; }
    public string? Bio { get; set; }
}