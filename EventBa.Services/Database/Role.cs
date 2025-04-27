using System;
using System.Collections.Generic;
using EventBa.Models.Enums;

namespace EventBa.Services.Database;

public partial class Role
{
    public Guid Id { get; set; }
    
    public UserRole Name { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
