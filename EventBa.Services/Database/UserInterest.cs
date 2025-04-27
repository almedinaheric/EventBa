using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class UserInterest
{
    public Guid UserId { get; set; }

    public Guid CategoryId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Category Category { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
