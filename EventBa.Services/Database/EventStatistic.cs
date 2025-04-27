using System;
using System.Collections.Generic;

namespace EventBa.Services.Database;

public partial class EventStatistic
{
    public Guid Id { get; set; }

    public Guid EventId { get; set; }

    public int TotalViews { get; set; }

    public int TotalFavorites { get; set; }

    public int TotalTicketsSold { get; set; }

    public decimal TotalRevenue { get; set; }

    public decimal AverageRating { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Event Event { get; set; } = null!;
}
