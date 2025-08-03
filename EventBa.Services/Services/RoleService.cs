using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class RoleService : BaseCRUDService<RoleResponseDto, Role, RoleSearchObject,
    RoleInsertRequestDto, RoleUpdateRequestDto>, IRoleService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }

    public RoleService(EventBaDbContext context, IMapper mapper) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public override IQueryable<Role> AddInclude(IQueryable<Role> query, RoleSearchObject? search = null)
    {
        query = query.Include(x => x.Users);
        return query;
    }
}