namespace EventBa.Model.Requests;

public class UserQuestionInsertRequestDto
{
    public Guid UserId { get; set; }
    public Guid ReceiverId { get; set; }
    public string Question { get; set; } = null!;
    public bool IsQuestionForAdmin { get; set; }
}