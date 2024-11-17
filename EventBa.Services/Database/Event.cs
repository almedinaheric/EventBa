using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class Event
{
    public DateTime? Created { get; set; }
    public DateTime? Updated { get; set; }
    public Guid EventId { get; set; }
    public string Name { get; set; } = null!;
    public Guid? CategoryId { get; set; }
    public string Type { get; set; } = null!;
    public string? Address { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? StartTime { get; set; }
    public TimeOnly? EndTime { get; set; }
    public string? Description { get; set; }
    public int? TicketsAvailable { get; set; }
    public Guid? OrganizerId { get; set; }
    public string Status { get; set; } = null!;
    public virtual Category? Category { get; set; }
    public virtual ICollection<Image> Images { get; set; } = new List<Image>();
    public virtual User? Organizer { get; set; }
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    public virtual ICollection<SalesReport> SalesReports { get; set; } = new List<SalesReport>();
    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
    public virtual ICollection<User> Users { get; set; } = new List<User>();
    public virtual ICollection<User> UsersNavigation { get; set; } = new List<User>();
}
