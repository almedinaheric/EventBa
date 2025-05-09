using EventBa.Model.Enums;

namespace EventBa.Services.Database;

public partial class Image
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
    public ImageType ImageType { get; set; }
    public int? Order { get; set; }
    public string FileName { get; set; } = null!;
    public int? FileSize { get; set; }
    public byte[]? ImageData { get; set; }
    public virtual Event? Event { get; set; }
    public virtual ICollection<EventGalleryImage> EventGalleryImages { get; set; } = new List<EventGalleryImage>();
    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
    public virtual User? User { get; set; }
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
