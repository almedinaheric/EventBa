using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class Tag
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
}
