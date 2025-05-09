namespace EventBa.Model.Requests;

public class UserInsertRequestDto
{
    public string FirstName { get; set; } = null!;
    public string? LastName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Bio { get; set; }
    public string Password { get; set; } = null!;
    public Guid? ProfileImageId { get; set; }
    public Guid RoleId { get; set; }
    public List<Guid> InterestCategoryIds { get; set; } = new();
}