using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class EventController : BaseController<EventResponse, EventSearchObject, EventRequest, EventRequest>
    {
        public EventController(
            ILogger<BaseController<EventResponse, EventSearchObject, EventRequest, EventRequest>> logger,
            IEventService service) : base(logger, service)
        {
        }
    }
}