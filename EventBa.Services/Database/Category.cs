namespace EventBa.Services.Database;

public partial class Category
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = null!;
    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
