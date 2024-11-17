namespace EventBa.Model.Responses;

public class UserResponse
{
    public Guid UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public Guid? RoleId { get; set; }
    public string? Bio { get; set; }
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public string RoleName { get; set; } = null!;
    public ICollection<Guid> EventIds { get; set; } = new List<Guid>();
    public ICollection<Guid> TicketInstanceIds { get; set; } = new List<Guid>();
}