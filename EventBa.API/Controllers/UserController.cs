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

    [AllowAnonymous]
    public override Task<UserResponseDto> Insert([FromBody] UserInsertRequestDto insert)
    {
        return _service.Insert(insert);
    }
    
    [HttpGet("{id}")]
    [Authorize]
    public override async Task<UserResponseDto> GetById([FromRoute] Guid id)
    {
        var user = await _userService.GetById(id);
        return user;
    }

    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        var profile = await _userService.GetUserAsync();
        return Ok(profile);
    }
    
    [HttpGet("profile/admin")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAdminProfile()
    {
        var profile = await _userService.GetUserAsync();
        return Ok(profile);
    }
    
    [HttpGet("profile/customer")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> GetCustomerProfile()
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
    
    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto request)
    {
        await _userService.ChangePasswordAsync(request);
        return Ok(new { message = "Password changed successfully." });
    }
}