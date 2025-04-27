using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class EventGalleryImage
{
    public Guid EventId { get; set; }

    public Guid ImageId { get; set; }

    public int Order { get; set; }

    public virtual Event Event { get; set; } = null!;

    public virtual Image Image { get; set; } = null!;
}
