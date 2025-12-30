using EventBa.Model.Enums;
using System.Text.Json.Serialization;

namespace EventBa.Model.Responses;

public class EventResponseDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string Location { get; set; } = null!;
    public string? SocialMediaLinks { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public int Capacity { get; set; }
    public int CurrentAttendees { get; set; }
    public int AvailableTicketsCount { get; set; }
    public EventStatus Status { get; set; }
    public EventType Type { get; set; }
    public bool IsPublished { get; set; }
    public bool IsFeatured { get; set; }
    public bool IsPaid { get; set; }

    public CategoryResponseDto Category { get; set; } = null!;

    [JsonIgnore] public ImageResponseDto? CoverImage { get; set; }

    [JsonPropertyName("coverImage")]
    public string? CoverImageData => CoverImage?.Data != null && CoverImage.Data.Length > 0
        ? $"data:image/jpeg;base64,{Convert.ToBase64String(CoverImage.Data)}"
        : null;

    [JsonPropertyName("coverImageId")] public Guid? CoverImageId => CoverImage?.Id;

    [JsonIgnore] public List<ImageResponseDto> GalleryImages { get; set; } = new();

    [JsonPropertyName("galleryImages")]
    public List<string> GalleryImageData => GalleryImages
        .Where(img => img != null && img.Data != null && img.Data.Length > 0)
        .Select(img => $"data:image/jpeg;base64,{Convert.ToBase64String(img.Data!)}")
        .ToList();

    [JsonPropertyName("galleryImageIds")]
    public List<Guid> GalleryImageIds => GalleryImages
        .Where(img => img != null && img.Id != Guid.Empty)
        .Select(img => img.Id)
        .ToList();

    public Guid OrganizerId { get; set; }
}