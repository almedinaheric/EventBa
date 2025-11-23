namespace EventBa.Model.Responses;

public class UserQuestionResponseDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid ReceiverId { get; set; }
    public string Question { get; set; }
    public string? Answer { get; set; }
    public bool IsQuestionForAdmin { get; set; }
    public bool IsAnswered { get; set; }
    public DateTime AskedAt { get; set; }
    public DateTime? AnsweredAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string? UserEmail { get; set; }
    public string? UserFullName { get; set; }
}