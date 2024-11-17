using AutoMapper;
using EventBa.Model.Helpers;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services
{
    /// <summary>
    /// Generic class designed to provide basic CRUD (Create, Read, Update, Delete) operations for various entity types.
    /// <para>
    /// The where clauses specify the constraints that these types must meet:
    /// TDb and T should be classes.
    /// TSearch, TInsert, and TUpdate should also be classes.
    /// TSearch must inherit from BaseSearchObject, which likely provides pagination or filtering properties.
    /// </para>
    /// </summary>
    /// <typeparam name="T">The model type that represents the data exposed to the user (e.g., UserDto).</typeparam>
    /// <typeparam name="TDb">The entity type that represents the database entity (e.g., UserEntity).</typeparam>
    /// <typeparam name="TSearch">The type representing the search filters for complex querying and pagination (e.g., UserSearchObject).</typeparam>
    /// <typeparam name="TInsert">The type used for inserting a new entity (e.g., UserInsertDto).</typeparam>
    /// <typeparam name="TUpdate">The type used for updating an existing entity (e.g., UserUpdateDto).</typeparam>
    public abstract class BaseService<T, TDb, TSearch, TInsert, TUpdate> : IBaseService<T, TSearch, TInsert, TUpdate>
        where TDb : class where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        protected EventbaDbContext _context;
        protected IMapper _mapper { get; set; }

        public BaseService(EventbaDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        /// <summary>
        /// Inserts a new entity of type TDb into the database.
        /// It maps the TInsert DTO to the TDb entity and saves the entity to the database.
        /// After saving, it maps the entity back to the T type and returns it.
        /// </summary>
        public virtual async Task<T> Insert(TInsert insert)
        {
            var set = _context.Set<TDb>();
            var entity = _mapper.Map<TDb>(insert);
            set.Add(entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        /// <summary>
        /// Retrieves a list of entities from the database based on search criteria.
        /// It applies filters and includes related entities as needed.
        /// The results are mapped to the T type and returned as a list.
        /// </summary>
        public virtual async Task<List<T>> Get(TSearch? search = null)
        {
            var query = _context.Set<TDb>().AsQueryable();
            query = AddFilter(query, search);
            query = AddInclude(query);
            var list = await query.ToListAsync();
            return _mapper.Map<List<T>>(list);
        }

        /// <summary>
        /// Retrieves a single entity by its ID.
        /// If the entity is not found, a KeyNotFoundException is thrown with a message that includes the entity type and ID.
        /// Otherwise, the entity is mapped to the T type and returned.
        /// </summary>
        public virtual async Task<T> GetById(int id)
        {
            var entity = await _context.Set<TDb>().FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"{typeof(TDb).Name} with ID {id} not found.");
            return _mapper.Map<T>(entity);
        }

        /// <summary>
        /// Retrieves a paginated list of entities based on search criteria.
        /// It applies filters and includes related entities, calculates the total count for pagination,
        /// and retrieves the specified page of results.
        /// The results are mapped to the T type and returned.
        /// </summary>
        public virtual async Task<PagedResult<T>> GetPage(TSearch? search = null)
        {
            var query = _context.Set<TDb>().AsQueryable();
            query = AddFilter(query, search);
            query = AddInclude(query);
            var totalCount = await query.CountAsync();
            var result = await query
                .Skip((int)((search?.Page - 1) * search?.PageSize))
                .Take((int)(search?.PageSize))
                .ToListAsync();
            return new PagedResult<T>
            {
                Result = _mapper.Map<List<T>>(result),
                Count = totalCount
            };
        }

        /// <summary>
        /// Updates an existing entity by ID.
        /// If the entity is not found, a KeyNotFoundException is thrown.
        /// If found, the method maps the TUpdate DTO to the entity, saves the changes, and returns the updated entity mapped to the T type.
        /// </summary>
        public virtual async Task<T> Update(int id, TUpdate update)
        {
            var set = _context.Set<TDb>();
            var entity = await set.FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"{typeof(TDb).Name} with ID {id} not found.");
            _mapper.Map(update, entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        /// <summary>
        /// Deletes an entity by ID.
        /// If the entity is not found, a KeyNotFoundException is thrown.
        /// If found, the entity is removed from the database and the changes are saved.
        /// The deleted entity is mapped to the T type and returned.
        /// </summary>
        public virtual async Task<T> Delete(int id)
        {
            var set = _context.Set<TDb>();
            var entity = await set.FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"{typeof(TDb).Name} with ID {id} not found.");
            _context.Remove(entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        /// <summary>
        /// Placeholder method to include related entities in the query.
        /// Can be overridden in subclasses to add specific include logic, such as using `.Include()` for related entities.
        /// </summary>
        public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query)
        {
            return query;
        }

        /// <summary>
        /// Placeholder method to add filtering to the query.
        /// Can be overridden in subclasses to apply custom filtering logic based on the TSearch object.
        /// </summary>
        public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }
    }
}