namespace EventBa.Services.Interfaces;

public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch>
    where T : class where TSearch : class
{
    Task<T> Insert(TInsert insert);
    Task<T> Update(Guid id, TUpdate update);
    Task<T> Delete(Guid id);
}