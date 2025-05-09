using EventBa.Model.Enums;

namespace EventBa.Services.Database;

public partial class Role
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public RoleName Name { get; set; }
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
