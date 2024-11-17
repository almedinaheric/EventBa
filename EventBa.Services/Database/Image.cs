using System;
using System.Collections.Generic;
using EventBa.Services.Database.Enums;

namespace EventBa.Services.Database;

public partial class Image
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid ImageId { get; set; }
    public byte[] ImageData { get; set; } = null!;
    public ImageType ImageType { get; set; }
    public Guid? UserId { get; set; }
    public Guid? EventId { get; set; }
    public virtual Event? Event { get; set; }
    public virtual User? User { get; set; }
}
