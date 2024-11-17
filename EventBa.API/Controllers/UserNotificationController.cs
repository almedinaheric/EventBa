using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class UserNotificationController : BaseController<UserNotificationResponse, UserNotificationSearchObject,
        UserNotificationRequest, UserNotificationRequest>
    {
        public UserNotificationController(
            ILogger<BaseController<UserNotificationResponse, UserNotificationSearchObject, UserNotificationRequest,
                UserNotificationRequest>> logger,
            IUserNotificationService service) : base(logger, service)
        {
        }
    }
}