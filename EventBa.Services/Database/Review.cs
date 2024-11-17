namespace EventBa.Services.Database;

public partial class Review
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid ReviewId { get; set; }
    public Guid? EventId { get; set; }
    public Guid? UserId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public virtual Event? Event { get; set; }
    public virtual User? User { get; set; }
}
