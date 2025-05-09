using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;

namespace EventBa.Services.Interfaces;

public interface IUserService : ICRUDService<UserResponseDto, UserSearchObject, UserInsertRequestDto, UserUpdateRequestDto>
{
    public Task<UserResponseDto> Login(string email, string password);
    public Task<UserResponseDto> GetUserAsync();
    public Task<User> GetUserEntityAsync();
    public Task<UserResponseDto> FollowUser(Guid userId);
    public Task<UserResponseDto> UnfollowUser(Guid userId);

}