using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class TicketInstanceController : BaseController<TicketInstanceResponse, TicketInstanceSearchObject,
        TicketInstanceRequest, TicketInstanceRequest>
    {
        public TicketInstanceController(
            ILogger<BaseController<TicketInstanceResponse, TicketInstanceSearchObject, TicketInstanceRequest,
                TicketInstanceRequest>> logger,
            ITicketInstanceService service) : base(logger, service)
        {
        }
    }
}