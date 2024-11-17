namespace EventBa.Services.Database;

public partial class User
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid UserId { get; set; }
    public string? FullName { get; set; }
    public string Email { get; set; } = null!;
    public Guid? RoleId { get; set; }
    public string PasswordHash { get; set; } = null!;
    public string PasswordSalt { get; set; } = null!;
    public string? Bio { get; set; }
    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
    public virtual ICollection<Image> Images { get; set; } = new List<Image>();
    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    public virtual Role? Role { get; set; }
    public virtual ICollection<TicketInstance> TicketInstances { get; set; } = new List<TicketInstance>();
    public virtual ICollection<UserNotification> UserNotifications { get; set; } = new List<UserNotification>();
    public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
    public virtual ICollection<Event> Events1 { get; set; } = new List<Event>();
    public virtual ICollection<Event> EventsNavigation { get; set; } = new List<Event>();
    public virtual ICollection<User> FollowerUsers { get; set; } = new List<User>();
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
