using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services
{
    public class TicketService : BaseService<TicketResponse, Ticket, TicketSearchObject, TicketRequest, TicketRequest>, ITicketService
    {
        public TicketService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}