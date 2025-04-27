using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class FavoriteEvent
{
    public Guid UserId { get; set; }

    public Guid EventId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Event Event { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
