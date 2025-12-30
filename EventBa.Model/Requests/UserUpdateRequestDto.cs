namespace EventBa.Model.Requests;

public class UserUpdateRequestDto
{
    public string? Email { get; set; } = null!;
    public string? FirstName { get; set; } = null!;
    public string? LastName { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Bio { get; set; }

    public Guid? ProfileImageId { get; set; }
    public List<Guid> InterestCategoryIds { get; set; } = new();
}