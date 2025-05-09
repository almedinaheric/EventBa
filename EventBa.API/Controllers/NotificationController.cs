using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
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
}