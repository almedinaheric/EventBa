using EventBa.Model.Helpers;

namespace EventBa.Services.Interfaces
{
    public interface IBaseService<T, TSearch, TInsert, TUpdate>
        where TSearch : class
        where TInsert : class
        where TUpdate : class
        where T : class
    {
        Task<T> Insert(TInsert insert);
        Task<List<T>> Get(TSearch search = null);
        Task<T> GetById(int id);
        Task<PagedResult<T>> GetPage(TSearch search = null); 
        Task<T> Update(int id, TUpdate update);
        Task<T> Delete(int id);
    }
}
