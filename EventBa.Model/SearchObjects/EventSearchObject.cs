using EventBa.Model.Enums;

namespace EventBa.Model.SearchObjects;

public class EventSearchObject : BaseSearchObject
{
    public string? SearchTerm { get; set; }
    public EventType? Type { get; set; }
    public bool? IsUpcoming { get; set; }
}