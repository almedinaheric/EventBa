namespace EventBa.Model.Helpers;

public class EmailModel
{
    public string Sender { get; set; } = null!;
    public string Recipient { get; set; } = null!;
    public string Subject { get; set; } = null!;
    public string Content { get; set; } = null!;
}