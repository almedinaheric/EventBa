namespace EventBa.Model.Helpers;

public class PagedResult<T>
{
    public List<T> Result { get; set; }
    public int? Count { get; set; }
}