namespace EventBa.Model.SearchObjects;

public class BaseSearchObject
{
    private int? _page = 1;
    public int? Page
    {
        get => _page;
        set => _page = (value < 1) ? 1 : value;
    }
    public int? PageSize { get; set; } = 10;
}