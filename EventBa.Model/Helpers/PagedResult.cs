using EventBa.Model.Helpers;

public class PagedResult<T>
{
    public List<T> Result { get; set; } = null!;
    public Meta Meta { get; set; } = null!;

    private PagedResult(List<T> items, int totalCount, int pageNumber, int pageSize)
    {
        Result = new List<T>();
        Meta = new Meta(totalCount, pageNumber, pageSize);
        Result.AddRange(items);
    }
    
    public static PagedResult<T> Create(List<T> items, int pageNumber, int pageSize, int totalCount)
    {
        return new PagedResult<T>(items, totalCount, pageNumber, pageSize);
    }
}