using AutoMapper;
using EventBa.Model.Enums;
using EventBa.Model.Helpers;
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

    public override async Task BeforeInsert(Ticket entity, TicketInsertRequestDto insert)
    {
        entity.QuantityAvailable = entity.Quantity;
        entity.QuantitySold = 0;
    }

    public override async Task<TicketResponseDto> Update(Guid id, TicketUpdateRequestDto update)
    {
        var set = _context.Set<Ticket>();
        var entity = await set.FindAsync(id);
        
        if (entity == null)
            throw new UserException("Ticket not found");
        
        var originalQuantity = entity.Quantity;
        var originalQuantityAvailable = entity.QuantityAvailable;
        var originalQuantitySold = entity.QuantitySold;
        
        _mapper.Map(update, entity);
        
        var quantityDifference = update.Quantity - originalQuantity;
        if (quantityDifference != 0)
        {
            var newQuantityAvailable = Math.Max(0, originalQuantityAvailable + quantityDifference);
            entity.QuantityAvailable = Math.Min(newQuantityAvailable, update.Quantity);
        }
        else
        {
            entity.QuantityAvailable = originalQuantityAvailable;
        }
        
        entity.QuantitySold = originalQuantitySold;
        
        await _context.SaveChangesAsync();
        return _mapper.Map<TicketResponseDto>(entity);
    }

    public override IQueryable<Ticket> AddInclude(IQueryable<Ticket> query, TicketSearchObject? search = null)
    {
        query = query.Include(x => x.Event)
                    .Include(x => x.TicketPurchases);
        return query;
    }

    public async Task<List<TicketResponseDto>> GetTicketsForEvent(Guid eventId)
    {
        var today = DateOnly.FromDateTime(DateTime.Now);
        var tickets = await _context.Tickets
            .Include(x => x.TicketPurchases)
            .Include(x => x.Event)
            .Where(x => x.EventId == eventId && x.Event.StartDate >= today)
            .ToListAsync();

        return _mapper.Map<List<TicketResponseDto>>(tickets);
    }
}