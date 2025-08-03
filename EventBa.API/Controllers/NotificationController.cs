using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class NotificationController : BaseCRUDController<NotificationResponseDto, NotificationSearchObject, NotificationInsertRequestDto,
    NotificationUpdateRequestDto>
{
    private readonly INotificationService _notificationService;

    public NotificationController(ILogger<BaseCRUDController<NotificationResponseDto, NotificationSearchObject, NotificationInsertRequestDto,
        NotificationUpdateRequestDto>> logger, INotificationService service) : base(logger, service)
    {
        _notificationService = service;
    }

    [HttpGet("my-notifications")]
    [Authorize]
    public async Task<IActionResult> GetMyNotifications()
    {
        var notifications = await _notificationService.GetMyNotifications();
        return Ok(notifications);
    }

    [HttpPost("{id}/mark-as-read")]
    [Authorize]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        await _notificationService.MarkAsRead(id);
        return Ok();
    }

    [HttpPost("mark-all-as-read")]
    [Authorize]
    public async Task<IActionResult> MarkAllAsRead()
    {
        await _notificationService.MarkAllAsRead();
        return Ok();
    }
}