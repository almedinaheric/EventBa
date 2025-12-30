using AutoMapper;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database.Context;

namespace EventBa.Services.Services;

public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch>
    where TSearch : BaseSearchObject where TDb : class where T : class
{
    private readonly EventBaDbContext _context;
    private readonly IMapper _mapper;

    public BaseCRUDService(EventBaDbContext context, IMapper mapper) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public virtual async Task BeforeInsert(TDb entity, TInsert insert)
    {
    }

    public virtual async Task BeforeUpdate(TDb entity, TUpdate update)
    {
    }

    public virtual async Task<T> Insert(TInsert insert)
    {
        var set = _context.Set<TDb>();
        var entity = _mapper.Map<TDb>(insert);
        set.Add(entity);
        await BeforeInsert(entity, insert);
        await _context.SaveChangesAsync();
        return _mapper.Map<T>(entity);
    }

    public virtual async Task<T> Update(Guid id, TUpdate update)
    {
        var set = _context.Set<TDb>();
        var entity = await set.FindAsync(id);
        _mapper.Map(update, entity);
        await BeforeUpdate(entity, update);
        await _context.SaveChangesAsync();
        return _mapper.Map<T>(entity);
    }

    public virtual async Task<T> Delete(Guid id)
    {
        var set = _context.Set<TDb>();
        var entity = await set.FindAsync(id);
        if (entity == null) return _mapper.Map<T>(null);

        _context.Remove(entity);
        await _context.SaveChangesAsync();
        return _mapper.Map<T>(entity);
    }
}