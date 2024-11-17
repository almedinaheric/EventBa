using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services
{
    public class TicketInstanceService : BaseService<TicketInstanceResponse, TicketInstance, TicketInstanceSearchObject,
        TicketInstanceRequest, TicketInstanceRequest>, ITicketInstanceService
    {
        public TicketInstanceService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}