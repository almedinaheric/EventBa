using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class NotificationController : BaseController<NotificationResponse, NotificationSearchObject, NotificationRequest, NotificationRequest>
    {
        public NotificationController(
            ILogger<BaseController<NotificationResponse, NotificationSearchObject, NotificationRequest, NotificationRequest>> logger,
            INotificationService service) : base(logger, service)
        {
        }
    }
}