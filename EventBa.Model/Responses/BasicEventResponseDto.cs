using EventBa.Model.Enums;
using System.Text.Json.Serialization;

namespace EventBa.Model.Responses;

public class BasicEventResponseDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public EventStatus Status { get; set; }
    public string Location { get; set; } = null!;
    
    [JsonIgnore]
    public ImageResponseDto? CoverImage { get; set; }
    
    [JsonPropertyName("coverImage")]
    public string? CoverImageData => CoverImage?.Data != null && CoverImage.Data.Length > 0
        ? $"data:image/jpeg;base64,{Convert.ToBase64String(CoverImage.Data)}"
        : null;
    
    public bool IsPaid { get; set; }
}