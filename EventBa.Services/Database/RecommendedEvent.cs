namespace EventBa.Services.Database;

public partial class RecommendedEvent
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid EventId { get; set; }
    public DateTime? CreatedAt { get; set; }
    public virtual Event Event { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}
