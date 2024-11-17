using EventBa.Model.Enums;

namespace EventBa.Model.Responses;

public class RoleResponse
{
    public Guid RoleId { get; set; }
    public RoleName RoleName { get; set; }
}