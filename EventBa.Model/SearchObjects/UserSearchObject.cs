namespace EventBa.Model.SearchObjects;

public class UserSearchObject : BaseSearchObject
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Email { get; set; }
    public string? SearchTerm { get; set; }
}