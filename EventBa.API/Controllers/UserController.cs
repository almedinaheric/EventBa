using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class UserController : BaseController<UserResponse, UserSearchObject, UserRequest, UserRequest>
    {
        public UserController(ILogger<BaseController<UserResponse, UserSearchObject, UserRequest, UserRequest>> logger,
            IUserService service) : base(logger, service)
        {
        }
    }
}