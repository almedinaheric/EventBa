using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class RecommendedResult
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid EventId1 { get; set; }

    public Guid EventId2 { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Event EventId1Navigation { get; set; } = null!;

    public virtual Event EventId2Navigation { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
