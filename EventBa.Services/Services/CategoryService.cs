using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class CategoryService : BaseCRUDService<CategoryResponseDto, Category, CategorySearchObject,
    CategoryInsertRequestDto, CategoryUpdateRequestDto>, ICategoryService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }

    public CategoryService(EventBaDbContext context, IMapper mapper) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public override IQueryable<Category> AddInclude(IQueryable<Category> query, CategorySearchObject? search = null)
    {
        query = query.Include(x => x.Events);
        return query;
    }

    public async Task<int> GetNumberOfItems()
    {
        return await _context.Categories.CountAsync();
    }
}