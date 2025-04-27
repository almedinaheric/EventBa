using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class UserConnection
{
    public Guid FollowerId { get; set; }

    public Guid FollowingId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual User Follower { get; set; } = null!;

    public virtual User Following { get; set; } = null!;
}
