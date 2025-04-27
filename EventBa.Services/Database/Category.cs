using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class Category
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public int EventCount { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual ICollection<Event> Events { get; set; } = new List<Event>();

    public virtual ICollection<UserInterest> UserInterests { get; set; } = new List<UserInterest>();
}
