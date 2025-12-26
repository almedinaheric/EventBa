namespace EventBa.Model.Requests;

public class ValidateResetCodeRequestDto
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
}

