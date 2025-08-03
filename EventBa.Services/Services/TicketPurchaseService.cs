using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class TicketPurchaseService : BaseCRUDService<TicketPurchaseResponseDto, TicketPurchase, TicketPurchaseSearchObject,
    TicketPurchaseInsertRequestDto, TicketPurchaseUpdateRequestDto>, ITicketPurchaseService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public TicketPurchaseService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(TicketPurchase entity, TicketPurchaseInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
    }

    public override IQueryable<TicketPurchase> AddInclude(IQueryable<TicketPurchase> query, TicketPurchaseSearchObject? search = null)
    {
        query = query.Include(x => x.User)
                    .Include(x => x.Ticket)
                    .ThenInclude(x => x.Event);
        return query;
    }
    
    public async Task<List<TicketPurchaseResponseDto>> GetMyPurchases()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var purchases = await _context.TicketPurchases
            .Include(x => x.Ticket)
            .ThenInclude(x => x.Event)
            .Where(x => x.UserId == currentUser.Id)
            .ToListAsync();

        return _mapper.Map<List<TicketPurchaseResponseDto>>(purchases);
    }
}