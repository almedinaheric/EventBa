namespace EventBa.Services.Database;

public partial class UserQuestion
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid UserId { get; set; }
    public Guid ReceiverId { get; set; }
    public Guid? EventId { get; set; }
    public string Question { get; set; } = null!;
    public string? Answer { get; set; }
    public bool IsQuestionForAdmin { get; set; }
    public bool IsAnswered { get; set; }
    public DateTime AskedAt { get; set; }
    public DateTime? AnsweredAt { get; set; }
    public virtual User Receiver { get; set; } = null!;
    public virtual User User { get; set; } = null!;
    public virtual Event? Event { get; set; }
}
