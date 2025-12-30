using System.Security.Cryptography;
using System.Text;
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
using Microsoft.EntityFrameworkCore.ChangeTracking;
using QRCoder;

namespace EventBa.Services.Services;

public class TicketPurchaseService : BaseCRUDService<TicketPurchaseResponseDto, TicketPurchase,
    TicketPurchaseSearchObject,
    TicketPurchaseInsertRequestDto, TicketPurchaseUpdateRequestDto>, ITicketPurchaseService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public TicketPurchaseService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context,
        mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(TicketPurchase entity, TicketPurchaseInsertRequestDto insert)
    {
        var currentUser = await _userService.GetUserEntityAsync();

        entity.EventId = insert.EventId;
        entity.TicketId = insert.TicketId;
        entity.UserId = currentUser.Id;

        var ticket = await _context.Tickets
            .AsNoTracking()
            .Include(t => t.Event)
            .FirstOrDefaultAsync(t => t.Id == insert.TicketId);

        if (ticket == null)
            throw new UserException("Ticket not found");

        if (ticket.QuantityAvailable <= 0)
            throw new UserException("No tickets available");

        entity.TicketCode = GenerateTicketCode();

        var qrData = $"EVENT:{ticket.EventId}|TICKET:{entity.TicketCode}|USER:{currentUser.Id}";
        entity.QrData = qrData;
        entity.QrVerificationHash = GenerateHash(qrData);

        using (var qrGenerator = new QRCodeGenerator())
        using (var qrCodeData = qrGenerator.CreateQrCode(qrData, QRCodeGenerator.ECCLevel.Q))
        using (var qrCode = new PngByteQRCode(qrCodeData))
        {
            entity.QrCodeImage = qrCode.GetGraphic(20);
        }

        entity.PricePaid = ticket.Price;
        entity.IsValid = true;

        var ticketToUpdate = await _context.Tickets
            .Include(t => t.Event)
            .FirstOrDefaultAsync(t => t.Id == insert.TicketId);

        if (ticketToUpdate == null)
            throw new UserException("Ticket not found");

        if (entity.EventId == Guid.Empty)
            entity.EventId = insert.EventId != Guid.Empty ? insert.EventId : ticketToUpdate.EventId;

        ticketToUpdate.QuantityAvailable--;
        ticketToUpdate.QuantitySold++;

        var eventEntity = ticketToUpdate.Event;
        if (eventEntity == null)
        {
            eventEntity = await _context.Events.FindAsync(insert.EventId);
            if (eventEntity == null)
                throw new UserException("Event not found");
        }

        eventEntity.AvailableTicketsCount = await _context.Tickets
            .Where(t => t.EventId == eventEntity.Id)
            .SumAsync(t => t.QuantityAvailable);

        var entityEntryFinal = _context.Entry(entity);

        if (entityEntryFinal.State == EntityState.Detached) _context.Entry(entity).State = EntityState.Added;
    }

    public override async Task<TicketPurchaseResponseDto> Insert(TicketPurchaseInsertRequestDto insert)
    {
        try
        {
            var set = _context.Set<TicketPurchase>();
            var entity = _mapper.Map<TicketPurchase>(insert);

            set.Add(entity);

            await BeforeInsert(entity, insert);

            var entityEntry = _context.Entry(entity);

            if (entityEntry.State == EntityState.Detached)
            {
                var eventId = entity.EventId;
                var ticketId = entity.TicketId;
                var userId = entity.UserId;
                var ticketCode = entity.TicketCode;
                var qrData = entity.QrData;
                var qrVerificationHash = entity.QrVerificationHash;
                var qrCodeImage = entity.QrCodeImage;
                var pricePaid = entity.PricePaid;
                var isValid = entity.IsValid;

                var newEntity = new TicketPurchase
                {
                    EventId = eventId,
                    TicketId = ticketId,
                    UserId = userId,
                    TicketCode = ticketCode,
                    QrData = qrData,
                    QrVerificationHash = qrVerificationHash,
                    QrCodeImage = qrCodeImage,
                    PricePaid = pricePaid,
                    IsValid = isValid
                };

                set.Add(newEntity);
                entity = newEntity;
                entityEntry = _context.Entry(entity);
            }

            if (entityEntry.State != EntityState.Added) entityEntry.State = EntityState.Added;

            await _context.SaveChangesAsync();

            var entityWithIncludes = await AddInclude(_context.Set<TicketPurchase>().Where(tp => tp.Id == entity.Id))
                .FirstOrDefaultAsync();

            if (entityWithIncludes != null) return _mapper.Map<TicketPurchaseResponseDto>(entityWithIncludes);

            return _mapper.Map<TicketPurchaseResponseDto>(entity);
        }
        catch (DbUpdateException dbEx)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    private string GenerateTicketCode()
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var random = new Random();
        var code = new string(Enumerable.Repeat(chars, 12)
            .Select(s => s[random.Next(s.Length)]).ToArray());
        return code;
    }

    private string GenerateHash(string input)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(input);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }

    public override IQueryable<TicketPurchase> AddInclude(IQueryable<TicketPurchase> query,
        TicketPurchaseSearchObject? search = null)
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

    public async Task<TicketPurchaseResponseDto> ValidateTicket(string ticketCode, Guid eventId)
    {
        var purchase = await _context.TicketPurchases
            .Include(x => x.Ticket)
            .ThenInclude(x => x.Event)
            .Include(x => x.User)
            .FirstOrDefaultAsync(x => x.TicketCode == ticketCode && x.EventId == eventId);

        if (purchase == null)
            throw new UserException("Ticket not found");

        if (!purchase.IsValid)
            throw new UserException("Ticket is no longer valid");

        if (purchase.IsUsed)
            throw new UserException("Ticket has already been used");

        purchase.IsValid = false;
        purchase.IsUsed = true;
        var now = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
        purchase.UsedAt = now;
        purchase.InvalidatedAt = now;

        var ticket = purchase.Ticket;

        var eventEntity = ticket.Event;
        if (eventEntity == null)
        {
            eventEntity = await _context.Events.FindAsync(eventId);
            if (eventEntity == null)
                throw new UserException("Event not found");
        }

        if (eventEntity.CurrentAttendees >= eventEntity.Capacity)
            throw new UserException("Event has reached maximum capacity");

        eventEntity.CurrentAttendees++;
        eventEntity.AvailableTicketsCount--;

        await _context.SaveChangesAsync();

        return _mapper.Map<TicketPurchaseResponseDto>(purchase);
    }
}