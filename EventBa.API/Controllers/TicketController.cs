using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class TicketController : BaseController<TicketResponse, TicketSearchObject, TicketRequest, TicketRequest>
    {
        public TicketController(ILogger<BaseController<TicketResponse, TicketSearchObject, TicketRequest, TicketRequest>> logger,
            ITicketService service) : base(logger, service)
        {
        }
    }
}