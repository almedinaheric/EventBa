namespace EventBa.Services.Interfaces;

public interface IService<T, TSearch> where T : class where TSearch : class
{
    Task<PagedResult<T>> Get(TSearch search = null);
    Task<T> GetById(Guid id);
}