using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class PaymentService : BaseCRUDService<PaymentResponseDto, Payment, PaymentSearchObject,
    PaymentInsertRequestDto, PaymentUpdateRequestDto>, IPaymentService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public PaymentService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(Payment entity, PaymentInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
    }

    public async Task<List<PaymentResponseDto>> GetMyPayments()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var payments = await _context.Payments
            .Where(x => x.UserId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<PaymentResponseDto>>(payments);
    }
}