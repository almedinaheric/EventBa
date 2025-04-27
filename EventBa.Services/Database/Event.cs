using System;
using System.Collections.Generic;
using EventBa.Models.Enums;

namespace EventBa.Services.Database;

public partial class Event
{
    public Guid Id { get; set; }

    public string Title { get; set; } = null!;

    public string Description { get; set; } = null!;

    public string Location { get; set; } = null!;

    public string? SocialMediaLinks { get; set; }

    public Guid? CoverImageId { get; set; }

    public DateOnly StartDate { get; set; }

    public DateOnly EndDate { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }
    
    public EventStatus Status { get; set; }

    public EventType Type { get; set; }

    public int Capacity { get; set; }

    public int CurrentAttendees { get; set; }

    public int AvailableTicketsCount { get; set; }

    public Guid CategoryId { get; set; }

    public bool IsFeatured { get; set; }

    public bool IsPublished { get; set; }

    public Guid OrganizerId { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Category Category { get; set; } = null!;

    public virtual Image? CoverImage { get; set; }

    public virtual ICollection<EventGalleryImage> EventGalleryImages { get; set; } = new List<EventGalleryImage>();

    public virtual ICollection<EventReview> EventReviews { get; set; } = new List<EventReview>();

    public virtual ICollection<EventStatistic> EventStatistics { get; set; } = new List<EventStatistic>();

    public virtual ICollection<FavoriteEvent> FavoriteEvents { get; set; } = new List<FavoriteEvent>();

    public virtual ICollection<Image> Images { get; set; } = new List<Image>();

    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

    public virtual User Organizer { get; set; } = null!;

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual ICollection<RecommendedResult> RecommendedResultEventId1Navigations { get; set; } = new List<RecommendedResult>();

    public virtual ICollection<RecommendedResult> RecommendedResultEventId2Navigations { get; set; } = new List<RecommendedResult>();

    public virtual ICollection<TicketPurchase> TicketPurchases { get; set; } = new List<TicketPurchase>();

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual ICollection<Tag> Tags { get; set; } = new List<Tag>();
}
