namespace EventBa.Services.Database;

public partial class User
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Bio { get; set; }
    public Guid? ProfileImageId { get; set; }
    public string PasswordHash { get; set; } = null!;
    public string PasswordSalt { get; set; } = null!;
    public Guid RoleId { get; set; }
    public string? FullName { get; set; }
    public virtual ICollection<EventReview> EventReviews { get; set; } = new List<EventReview>();
    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
    public virtual ICollection<Image> Images { get; set; } = new List<Image>();
    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public virtual Image? ProfileImage { get; set; }
    public virtual ICollection<RecommendedEvent> RecommendedEvents { get; set; } = new List<RecommendedEvent>();
    public virtual Role Role { get; set; } = null!;
    public virtual ICollection<TicketPurchase> TicketPurchases { get; set; } = new List<TicketPurchase>();
    public virtual ICollection<UserQuestion> UserQuestionReceivers { get; set; } = new List<UserQuestion>();
    public virtual ICollection<UserQuestion> UserQuestionUsers { get; set; } = new List<UserQuestion>();
    public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
    public virtual ICollection<Event> EventsNavigation { get; set; } = new List<Event>();
    public virtual ICollection<User> Followers { get; set; } = new List<User>();
    public virtual ICollection<User> Followings { get; set; } = new List<User>();
}
