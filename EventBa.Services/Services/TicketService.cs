using AutoMapper;
using EventBa.Model.Enums;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class TicketService : BaseCRUDService<TicketResponseDto, Ticket, TicketSearchObject,
    TicketInsertRequestDto, TicketUpdateRequestDto>, ITicketService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }

    public TicketService(EventBaDbContext context, IMapper mapper) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public override IQueryable<Ticket> AddInclude(IQueryable<Ticket> query, TicketSearchObject? search = null)
    {
        query = query.Include(x => x.Event)
                    .Include(x => x.TicketPurchases);
        return query;
    }

    public async Task<List<TicketResponseDto>> GetTicketsForEvent(Guid eventId)
    {
        var tickets = await _context.Tickets
            .Include(x => x.TicketPurchases)
            .Where(x => x.EventId == eventId && x.Event.Status == EventStatus.Upcoming)
            .ToListAsync();

        return _mapper.Map<List<TicketResponseDto>>(tickets);
    }
}