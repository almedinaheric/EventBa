using EventBa.Model.Enums;

namespace EventBa.Services.Database;

public partial class Role
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid RoleId { get; set; }
    public RoleName RoleName { get; set; }
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
