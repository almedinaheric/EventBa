using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class RoleController : BaseController<RoleResponse, RoleSearchObject, RoleRequest, RoleRequest>
    {
        public RoleController(
            ILogger<BaseController<RoleResponse, RoleSearchObject, RoleRequest, RoleRequest>> logger,
            IRoleService service) : base(logger, service)
        {
        }
    }
}