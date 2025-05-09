namespace EventBa.Services.Database;

public partial class EventReview
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid UserId { get; set; }
    public Guid EventId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public virtual Event Event { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}
