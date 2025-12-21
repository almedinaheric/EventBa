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
using QRCoder;

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
        var currentUser = await _userService.GetUserEntityAsync();
        entity.User = currentUser;
        entity.UserId = currentUser.Id;

        // Detach any existing tracked ticket entity to ensure we get fresh data
        var existingTicketEntity = await _context.Tickets.FindAsync(insert.TicketId);
        if (existingTicketEntity != null)
        {
            var entry = _context.Entry(existingTicketEntity);
            if (entry.State != EntityState.Detached)
            {
                entry.State = EntityState.Detached;
            }
        }

        // Check ticket availability - reload from database to get current values
        var ticket = await _context.Tickets
            .AsNoTracking()
            .Include(t => t.Event)
            .FirstOrDefaultAsync(t => t.Id == insert.TicketId);

        if (ticket == null)
            throw new UserException("Ticket not found");

        if (ticket.QuantityAvailable <= 0)
            throw new UserException("No tickets available");

        // Generate unique ticket code
        entity.TicketCode = GenerateTicketCode();

        // Generate QR code data
        var qrData = $"EVENT:{ticket.EventId}|TICKET:{entity.TicketCode}|USER:{currentUser.Id}";
        entity.QrData = qrData;
        entity.QrVerificationHash = GenerateHash(qrData);

        // Generate QR code image
        using (var qrGenerator = new QRCodeGenerator())
        using (var qrCodeData = qrGenerator.CreateQrCode(qrData, QRCodeGenerator.ECCLevel.Q))
        using (var qrCode = new PngByteQRCode(qrCodeData))
        {
            entity.QrCodeImage = qrCode.GetGraphic(20);
        }

        // Store the price paid at purchase time (for reporting even if ticket price changes later)
        entity.PricePaid = ticket.Price;
        entity.IsValid = true;

        // Reload ticket entity for tracking and update quantities
        var ticketToUpdate = await _context.Tickets
            .Include(t => t.Event)
            .FirstOrDefaultAsync(t => t.Id == insert.TicketId);

        if (ticketToUpdate == null)
            throw new UserException("Ticket not found");

        // Update ticket quantities
        ticketToUpdate.QuantityAvailable--;
        ticketToUpdate.QuantitySold++;

        // Update event attendees
        var eventEntity = ticketToUpdate.Event;
        eventEntity.CurrentAttendees++;
        eventEntity.AvailableTicketsCount = await _context.Tickets
            .Where(t => t.EventId == eventEntity.Id)
            .SumAsync(t => t.QuantityAvailable);
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

    public async Task<TicketPurchaseResponseDto> ValidateTicket(string ticketCode, Guid eventId)
    {
        // Find the ticket purchase by ticket code and event ID
        var purchase = await _context.TicketPurchases
            .Include(x => x.Ticket)
            .ThenInclude(x => x.Event)
            .Include(x => x.User)
            .FirstOrDefaultAsync(x => x.TicketCode == ticketCode && x.EventId == eventId);

        if (purchase == null)
            throw new UserException("Ticket not found");

        // Validate ticket
        if (!purchase.IsValid)
            throw new UserException("Ticket is no longer valid");

        if (purchase.IsUsed)
            throw new UserException("Ticket has already been used");

        // Mark ticket as used
        purchase.IsValid = false;
        purchase.IsUsed = true;
        purchase.UsedAt = DateTime.UtcNow;
        purchase.InvalidatedAt = DateTime.UtcNow;

        // Update ticket quantities
        var ticket = purchase.Ticket;
        ticket.QuantityAvailable--;
        ticket.QuantitySold++;

        // Update event attendees
        var eventEntity = ticket.Event;
        eventEntity.CurrentAttendees++;
        eventEntity.AvailableTicketsCount = await _context.Tickets
            .Where(t => t.EventId == eventEntity.Id)
            .SumAsync(t => t.QuantityAvailable);

        await _context.SaveChangesAsync();

        return _mapper.Map<TicketPurchaseResponseDto>(purchase);
    }
}