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
        // Store the entity entry to check state later
        var entityEntryBefore = _context.Entry(entity);
        Console.WriteLine($"BeforeInsert: Entity state at start: {entityEntryBefore.State}");
        
        var currentUser = await _userService.GetUserEntityAsync();
        
        // Ensure EventId and TicketId are set from the insert DTO first
        entity.EventId = insert.EventId;
        entity.TicketId = insert.TicketId;
        entity.UserId = currentUser.Id;
        
        // Don't set navigation properties - just set the foreign key IDs
        // Setting navigation properties can cause tracking issues
        // entity.User = ...; // Don't set this, let EF Core handle it via UserId

        // Don't detach entities - this might be causing the TicketPurchase to become detached
        // Instead, just query with AsNoTracking for read-only checks

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

        // Check entity state before loading related entities
        var entityEntryMid = _context.Entry(entity);
        Console.WriteLine($"BeforeInsert: Entity state before loading ticket: {entityEntryMid.State}");
        
        // Reload ticket entity for tracking and update quantities
        var ticketToUpdate = await _context.Tickets
            .Include(t => t.Event)
            .FirstOrDefaultAsync(t => t.Id == insert.TicketId);

        if (ticketToUpdate == null)
            throw new UserException("Ticket not found");

        // Check entity state after loading ticket
        var entityEntryAfterTicket = _context.Entry(entity);
        Console.WriteLine($"BeforeInsert: Entity state after loading ticket: {entityEntryAfterTicket.State}");

        // Ensure EventId is set on the entity (from insert DTO or ticket)
        if (entity.EventId == Guid.Empty)
        {
            entity.EventId = insert.EventId != Guid.Empty ? insert.EventId : ticketToUpdate.EventId;
        }

        // Update ticket quantities (decrease available, increase sold)
        ticketToUpdate.QuantityAvailable--;
        ticketToUpdate.QuantitySold++;

        // Update event available tickets count
        // Ensure Event is loaded and tracked
        var eventEntity = ticketToUpdate.Event;
        if (eventEntity == null)
        {
            // Load event separately if not loaded via Include
            eventEntity = await _context.Events.FindAsync(insert.EventId);
            if (eventEntity == null)
                throw new UserException("Event not found");
        }
        
        // Note: CurrentAttendees is NOT incremented here - it will be incremented when the ticket is validated/scanned
        // This way we track actual attendance, not just ticket sales
        // Recalculate available tickets count from all tickets for this event
        eventEntity.AvailableTicketsCount = await _context.Tickets
            .Where(t => t.EventId == eventEntity.Id)
            .SumAsync(t => t.QuantityAvailable);
        
        // Final check of entity state
        var entityEntryFinal = _context.Entry(entity);
        Console.WriteLine($"BeforeInsert: Entity state at end: {entityEntryFinal.State}");
        
        // If entity became detached, re-attach it
        if (entityEntryFinal.State == EntityState.Detached)
        {
            Console.WriteLine("WARNING: Entity became detached in BeforeInsert! Re-attaching...");
            _context.Entry(entity).State = EntityState.Added;
            Console.WriteLine($"Entity state after re-attaching: {_context.Entry(entity).State}");
        }
    }

    public override async Task<TicketPurchaseResponseDto> Insert(TicketPurchaseInsertRequestDto insert)
    {
        try
        {
            Console.WriteLine($"TicketPurchaseService.Insert called for TicketId: {insert.TicketId}, EventId: {insert.EventId}");
            
            var set = _context.Set<TicketPurchase>();
            var entity = _mapper.Map<TicketPurchase>(insert);
            
            Console.WriteLine($"Mapped entity - EventId: {entity.EventId}, TicketId: {entity.TicketId}, UserId: {entity.UserId}");
            
            set.Add(entity);
            Console.WriteLine($"Entity added to context. State: {_context.Entry(entity).State}");
            
            await BeforeInsert(entity, insert);
            Console.WriteLine($"BeforeInsert completed. Entity EventId: {entity.EventId}, TicketId: {entity.TicketId}, UserId: {entity.UserId}");
            
            // Ensure entity is still tracked and in Added state before SaveChanges
            var entityEntry = _context.Entry(entity);
            Console.WriteLine($"Entity state after BeforeInsert: {entityEntry.State}");
            
            if (entityEntry.State == EntityState.Detached)
            {
                Console.WriteLine("Entity was detached! Re-adding to context...");
                // Clear any navigation properties that might be causing issues
                var eventId = entity.EventId;
                var ticketId = entity.TicketId;
                var userId = entity.UserId;
                var ticketCode = entity.TicketCode;
                var qrData = entity.QrData;
                var qrVerificationHash = entity.QrVerificationHash;
                var qrCodeImage = entity.QrCodeImage;
                var pricePaid = entity.PricePaid;
                var isValid = entity.IsValid;
                
                // Create a new entity instance to avoid tracking conflicts
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
                Console.WriteLine($"Entity state after re-adding: {entityEntry.State}");
            }
            
            Console.WriteLine($"Entity state before SaveChanges: {entityEntry.State}");
            
            if (entityEntry.State != EntityState.Added)
            {
                Console.WriteLine($"WARNING: Entity is not in Added state! Current state: {entityEntry.State}. Attempting to set to Added...");
                entityEntry.State = EntityState.Added;
            }
            
            await _context.SaveChangesAsync();
            Console.WriteLine($"SaveChangesAsync completed successfully. Entity ID: {entity.Id}");
            
            // Reload the entity with all includes to ensure related entities are populated
            var entityWithIncludes = await AddInclude(_context.Set<TicketPurchase>().Where(tp => tp.Id == entity.Id))
                .FirstOrDefaultAsync();
            
            if (entityWithIncludes != null)
            {
                Console.WriteLine($"Reloaded entity with includes. Returning mapped response.");
                return _mapper.Map<TicketPurchaseResponseDto>(entityWithIncludes);
            }
            
            Console.WriteLine($"Entity not found after reload. Returning mapped original entity.");
            return _mapper.Map<TicketPurchaseResponseDto>(entity);
        }
        catch (DbUpdateException dbEx)
        {
            Console.WriteLine($"DbUpdateException in TicketPurchaseService.Insert: {dbEx.Message}");
            if (dbEx.InnerException != null)
            {
                Console.WriteLine($"Inner exception: {dbEx.InnerException.Message}");
            }
            throw;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Exception in TicketPurchaseService.Insert for TicketId: {insert.TicketId}, EventId: {insert.EventId}. Error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
            if (ex.InnerException != null)
            {
                Console.WriteLine($"Inner exception: {ex.InnerException.Message}");
            }
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
        // Convert to local time (Unspecified kind) for PostgreSQL timestamp without time zone
        var now = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
        purchase.UsedAt = now;
        purchase.InvalidatedAt = now;

        // Update ticket quantities
        var ticket = purchase.Ticket;
        // Note: QuantityAvailable and QuantitySold are already updated when ticket was purchased
        // We don't need to update them again here, just mark the ticket as used
        
        // Update event attendees - increment when ticket is validated/scanned (actual attendance)
        var eventEntity = ticket.Event;
        if (eventEntity == null)
        {
            // Load event separately if not loaded via Include
            eventEntity = await _context.Events.FindAsync(eventId);
            if (eventEntity == null)
                throw new UserException("Event not found");
        }
        
        // Check if we would exceed capacity
        if (eventEntity.CurrentAttendees >= eventEntity.Capacity)
        {
            throw new UserException("Event has reached maximum capacity");
        }
        
        // Increment current attendees when ticket is validated (actual attendance tracking)
        eventEntity.CurrentAttendees++;
        // Decrease available tickets count
        eventEntity.AvailableTicketsCount--;

        await _context.SaveChangesAsync();

        return _mapper.Map<TicketPurchaseResponseDto>(purchase);
    }
}