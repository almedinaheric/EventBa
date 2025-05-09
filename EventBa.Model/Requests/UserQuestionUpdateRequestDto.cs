namespace EventBa.Model.Requests;

public class UserQuestionUpdateRequestDto
{
    public Guid Id { get; set; }
    public string? Answer { get; set; }
    public bool IsAnswered { get; set; }
    public DateTime? AnsweredAt { get; set; }
}