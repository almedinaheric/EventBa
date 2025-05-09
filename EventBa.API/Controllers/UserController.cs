using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class UserController : BaseCRUDController<UserResponseDto, UserSearchObject, UserInsertRequestDto,
    UserUpdateRequestDto>
{
    private readonly IUserService _userService;

    public UserController(ILogger<BaseCRUDController<UserResponseDto, UserSearchObject, UserInsertRequestDto,
        UserUpdateRequestDto>> logger, IUserService service) : base(logger, service)
    {
        _userService = service;
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public override async Task<UserResponseDto> Insert([FromBody] UserInsertRequestDto insert)
    {
        return await _service.Insert(insert);
    }

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var profile = await _userService.GetUserAsync();
        return Ok(profile);
    }

    [HttpPost("{userId}/follow")]
    public async Task<IActionResult> FollowUser(Guid userId)
    {
        return Ok(await _userService.FollowUser(userId));
    }

    [HttpPost("{userId}/unfollow")]
    public async Task<IActionResult> UnfollowUser(Guid userId)
    {
        return Ok(await _userService.UnfollowUser(userId));
    }
}