namespace EventBa.Model.Responses;

public class UserResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Bio { get; set; } = null!;
    public string? PhoneNumber { get; set; }

    public RoleResponseDto Role { get; set; } = null!;
    public ImageResponseDto? ProfileImage { get; set; }
    public List<CategoryResponseDto> Interests { get; set; } = new();
    public List<BasicUserResponseDto> Followers { get; set; } = new();
    public List<BasicUserResponseDto> Following { get; set; } = new();
    public List<BasicEventResponseDto> FavoriteEvents { get; set; } = new();
}