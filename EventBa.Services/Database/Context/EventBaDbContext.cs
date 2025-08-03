using EventBa.Model.Enums;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Database.Context;

public partial class EventBaDbContext : DbContext
{
    public EventBaDbContext()
    {
    }

    public EventBaDbContext(DbContextOptions<EventBaDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Event> Events { get; set; }

    public virtual DbSet<EventGalleryImage> EventGalleryImages { get; set; }

    public virtual DbSet<EventReview> EventReviews { get; set; }

    public virtual DbSet<EventStatistic> EventStatistics { get; set; }

    public virtual DbSet<Image> Images { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<RecommendedEvent> RecommendedEvents { get; set; }

    public virtual DbSet<Role> Roles { get; set; }
    
    public virtual DbSet<Ticket> Tickets { get; set; }

    public virtual DbSet<TicketPurchase> TicketPurchases { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserQuestion> UserQuestions { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseNpgsql("Name=ConnectionStrings:DefaultConnection");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("uuid-ossp");

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("categories_pkey");

            entity.ToTable("categories");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.EventCount)
                .HasDefaultValue(0)
                .HasColumnName("event_count");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
        });

        modelBuilder.Entity<Event>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("events_pkey");

            entity.ToTable("events");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.AvailableTicketsCount)
                .HasDefaultValue(0)
                .HasColumnName("available_tickets_count");
            entity.Property(e => e.Capacity).HasColumnName("capacity");
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.CoverImageId).HasColumnName("cover_image_id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.CurrentAttendees)
                .HasDefaultValue(0)
                .HasColumnName("current_attendees");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.EndDate).HasColumnName("end_date");
            entity.Property(e => e.EndTime).HasColumnName("end_time");
            entity.Property(e => e.IsFeatured)
                .HasDefaultValue(false)
                .HasColumnName("is_featured");
            entity.Property(e => e.IsPublished)
                .HasDefaultValue(false)
                .HasColumnName("is_published");
            entity.Property(e => e.Location)
                .HasMaxLength(255)
                .HasColumnName("location");
            entity.Property(e => e.OrganizerId).HasColumnName("organizer_id");
            entity.Property(e => e.SocialMediaLinks)
                .HasColumnType("jsonb")
                .HasColumnName("social_media_links");
            entity.Property(e => e.StartDate).HasColumnName("start_date");
            entity.Property(e => e.StartTime).HasColumnName("start_time");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Upcoming'::character varying")
                .HasConversion(
                    v => v.ToString(),
                    v => (EventStatus)Enum.Parse(typeof(EventStatus), v))
                .HasColumnName("status")
                .HasColumnType("text");
            entity.Property(e => e.Title)
                .HasMaxLength(100)
                .HasColumnName("title");
            entity.Property(e => e.Type)
                .HasDefaultValueSql("'Public'::character varying")
                .HasConversion(
                    v => v.ToString(),
                    v => (EventType)Enum.Parse(typeof(EventType), v))
                .HasColumnName("type")
                .HasColumnType("text");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.Category).WithMany(p => p.Events)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("events_category_id_fkey");

            entity.HasOne(d => d.CoverImage).WithMany(p => p.Events)
                .HasForeignKey(d => d.CoverImageId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_event_cover_image");

            entity.HasOne(d => d.Organizer).WithMany(p => p.Events)
                .HasForeignKey(d => d.OrganizerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("events_organizer_id_fkey");
        });

        modelBuilder.Entity<EventGalleryImage>(entity =>
        {
            entity.HasKey(e => new { e.EventId, e.ImageId }).HasName("event_gallery_images_pkey");

            entity.ToTable("event_gallery_images");

            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.ImageId).HasColumnName("image_id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.Order).HasColumnName("order");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.Event).WithMany(p => p.EventGalleryImages)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("event_gallery_images_event_id_fkey");

            entity.HasOne(d => d.Image).WithMany(p => p.EventGalleryImages)
                .HasForeignKey(d => d.ImageId)
                .HasConstraintName("event_gallery_images_image_id_fkey");
        });

        modelBuilder.Entity<EventReview>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("event_reviews_pkey");

            entity.ToTable("event_reviews");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.Comment).HasColumnName("comment");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.Rating).HasColumnName("rating");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.EventReviews)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("event_reviews_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.EventReviews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("event_reviews_user_id_fkey");
        });

        modelBuilder.Entity<EventStatistic>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("event_statistics_pkey");

            entity.ToTable("event_statistics");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.AverageRating)
                .HasPrecision(3, 2)
                .HasColumnName("average_rating");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.TotalFavorites)
                .HasDefaultValue(0)
                .HasColumnName("total_favorites");
            entity.Property(e => e.TotalRevenue)
                .HasPrecision(10, 2)
                .HasColumnName("total_revenue");
            entity.Property(e => e.TotalTicketsSold)
                .HasDefaultValue(0)
                .HasColumnName("total_tickets_sold");
            entity.Property(e => e.TotalViews)
                .HasDefaultValue(0)
                .HasColumnName("total_views");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.Event).WithMany(p => p.EventStatistics)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("event_statistics_event_id_fkey");
        });

        modelBuilder.Entity<Image>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("images_pkey");

            entity.ToTable("images");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.FileName)
                .HasMaxLength(255)
                .HasColumnName("file_name");
            entity.Property(e => e.FileSize).HasColumnName("file_size");
            entity.Property(e => e.ImageData).HasColumnName("image_data");
            entity.Property(e => e.ImageType)
                .HasConversion(
                    v => v.ToString(),
                    v => (ImageType)Enum.Parse(typeof(ImageType), v))
                .HasColumnName("image_type")
                .HasColumnType("text");
            entity.Property(e => e.Order).HasColumnName("order");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.Images)
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("images_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.Images)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("images_user_id_fkey");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("notifications_pkey");

            entity.ToTable("notifications");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.Content).HasColumnName("content");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.IsImportant)
                .HasDefaultValue(false)
                .HasColumnName("is_important");
            entity.Property(e => e.IsSystemNotification)
                .HasDefaultValue(false)
                .HasColumnName("is_system_notification");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Sent'::character varying")
                .HasConversion(
                    v => v.ToString(),
                    v => (NotificationStatus)Enum.Parse(typeof(NotificationStatus), v))
                .HasColumnName("status")
                .HasColumnType("text");
            entity.Property(e => e.Title)
                .HasMaxLength(100)
                .HasColumnName("title");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("notifications_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("notifications_user_id_fkey");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("payments_pkey");

            entity.ToTable("payments");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.Amount)
                .HasPrecision(10, 2)
                .HasColumnName("amount");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.Currency)
                .HasMaxLength(3)
                .HasDefaultValueSql("'USD'::character varying")
                .HasColumnName("currency");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'Pending'::character varying")
                .HasConversion(
                    v => v.ToString(),
                    v => (PaymentStatus)Enum.Parse(typeof(PaymentStatus), v))
                .HasColumnName("status")
                .HasColumnType("text");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.Payments)
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("payments_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.Payments)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("payments_user_id_fkey");
        });

        modelBuilder.Entity<RecommendedEvent>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("recommended_events_pkey");

            entity.ToTable("recommended_events");

            entity.HasIndex(e => new { e.UserId, e.EventId }, "recommended_events_user_id_event_id_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.RecommendedEvents)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("recommended_events_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.RecommendedEvents)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("recommended_events_user_id_fkey");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("roles_pkey");

            entity.ToTable("roles");

            entity.HasIndex(e => e.Name, "roles_name_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.Name)
                .HasConversion(
                    v => v.ToString(),
                    v => (RoleName)Enum.Parse(typeof(RoleName), v))
                .HasColumnName("name")
                .HasColumnType("text");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
        });

        modelBuilder.Entity<Ticket>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("tickets_pkey");

            entity.ToTable("tickets");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.Price)
                .HasPrecision(10, 2)
                .HasColumnName("price");
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.QuantityAvailable).HasColumnName("quantity_available");
            entity.Property(e => e.QuantitySold)
                .HasDefaultValue(0)
                .HasColumnName("quantity_sold");
            entity.Property(e => e.SaleEndDate)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("sale_end_date");
            entity.Property(e => e.SaleStartDate)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("sale_start_date");
            entity.Property(e => e.TicketType)
                .HasConversion(
                    v => v.ToString(),
                    v => (TicketType)Enum.Parse(typeof(TicketType), v))
                .HasColumnName("ticket_type")
                .HasColumnType("text");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.Event).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("tickets_event_id_fkey");
        });

        modelBuilder.Entity<TicketPurchase>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("ticket_purchases_pkey");

            entity.ToTable("ticket_purchases");

            entity.HasIndex(e => e.TicketCode, "ticket_purchases_ticket_code_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.InvalidatedAt)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("invalidated_at");
            entity.Property(e => e.IsUsed)
                .HasDefaultValue(false)
                .HasColumnName("is_used");
            entity.Property(e => e.IsValid)
                .HasDefaultValue(true)
                .HasColumnName("is_valid");
            entity.Property(e => e.QrCodeImage).HasColumnName("qr_code_image");
            entity.Property(e => e.QrData).HasColumnName("qr_data");
            entity.Property(e => e.QrVerificationHash)
                .HasMaxLength(128)
                .HasColumnName("qr_verification_hash");
            entity.Property(e => e.TicketCode)
                .HasMaxLength(20)
                .HasColumnName("ticket_code");
            entity.Property(e => e.TicketId).HasColumnName("ticket_id");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UsedAt)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("used_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.TicketPurchases)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("ticket_purchases_event_id_fkey");

            entity.HasOne(d => d.Ticket).WithMany(p => p.TicketPurchases)
                .HasForeignKey(d => d.TicketId)
                .HasConstraintName("ticket_purchases_ticket_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.TicketPurchases)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("ticket_purchases_user_id_fkey");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("users_pkey");

            entity.ToTable("users");

            entity.HasIndex(e => e.Email, "users_email_key").IsUnique();

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.Bio).HasColumnName("bio");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .HasColumnName("email");
            entity.Property(e => e.FirstName)
                .HasMaxLength(50)
                .HasColumnName("first_name");
            entity.Property(e => e.FullName)
                .HasMaxLength(101)
                .HasComputedColumnSql("(((first_name)::text || ' '::text) || (last_name)::text)", true)
                .HasColumnName("full_name");
            entity.Property(e => e.LastName)
                .HasMaxLength(50)
                .HasColumnName("last_name");
            entity.Property(e => e.PasswordHash)
                .HasMaxLength(255)
                .HasColumnName("password_hash");
            entity.Property(e => e.PasswordSalt)
                .HasMaxLength(255)
                .HasColumnName("password_salt");
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(20)
                .HasColumnName("phone_number");
            entity.Property(e => e.ProfileImageId).HasColumnName("profile_image_id");
            entity.Property(e => e.RoleId).HasColumnName("role_id");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");

            entity.HasOne(d => d.ProfileImage).WithMany(p => p.Users)
                .HasForeignKey(d => d.ProfileImageId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_user_profile_image");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("users_role_id_fkey");

            entity.HasMany(d => d.Categories).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "UserInterest",
                    r => r.HasOne<Category>().WithMany()
                        .HasForeignKey("CategoryId")
                        .HasConstraintName("user_interests_category_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .HasConstraintName("user_interests_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "CategoryId").HasName("user_interests_pkey");
                        j.ToTable("user_interests");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("CategoryId").HasColumnName("category_id");
                    });

            entity.HasMany(d => d.EventsNavigation).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "FavoriteEvent",
                    r => r.HasOne<Event>().WithMany()
                        .HasForeignKey("EventId")
                        .HasConstraintName("favorite_events_event_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .HasConstraintName("favorite_events_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "EventId").HasName("favorite_events_pkey");
                        j.ToTable("favorite_events");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("EventId").HasColumnName("event_id");
                    });

            entity.HasMany(d => d.Followers).WithMany(p => p.Followings)
                .UsingEntity<Dictionary<string, object>>(
                    "UserConnection",
                    r => r.HasOne<User>().WithMany()
                        .HasForeignKey("FollowerId")
                        .HasConstraintName("user_connections_follower_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("FollowingId")
                        .HasConstraintName("user_connections_following_id_fkey"),
                    j =>
                    {
                        j.HasKey("FollowerId", "FollowingId").HasName("user_connections_pkey");
                        j.ToTable("user_connections");
                        j.IndexerProperty<Guid>("FollowerId").HasColumnName("follower_id");
                        j.IndexerProperty<Guid>("FollowingId").HasColumnName("following_id");
                    });

            entity.HasMany(d => d.Followings).WithMany(p => p.Followers)
                .UsingEntity<Dictionary<string, object>>(
                    "UserConnection",
                    r => r.HasOne<User>().WithMany()
                        .HasForeignKey("FollowingId")
                        .HasConstraintName("user_connections_following_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("FollowerId")
                        .HasConstraintName("user_connections_follower_id_fkey"),
                    j =>
                    {
                        j.HasKey("FollowerId", "FollowingId").HasName("user_connections_pkey");
                        j.ToTable("user_connections");
                        j.IndexerProperty<Guid>("FollowerId").HasColumnName("follower_id");
                        j.IndexerProperty<Guid>("FollowingId").HasColumnName("following_id");
                    });
        });

        modelBuilder.Entity<UserQuestion>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("user_questions_pkey");

            entity.ToTable("user_questions");

            entity.Property(e => e.Id)
                .HasDefaultValueSql("uuid_generate_v4()")
                .HasColumnName("id");
            entity.Property(e => e.Answer).HasColumnName("answer");
            entity.Property(e => e.AnsweredAt)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("answered_at");
            entity.Property(e => e.AskedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("asked_at");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created_at");
            entity.Property(e => e.IsAnswered)
                .HasDefaultValue(false)
                .HasColumnName("is_answered");
            entity.Property(e => e.IsQuestionForAdmin)
                .HasDefaultValue(false)
                .HasColumnName("is_question_for_admin");
            entity.Property(e => e.Question).HasColumnName("question");
            entity.Property(e => e.ReceiverId).HasColumnName("receiver_id");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated_at");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Receiver).WithMany(p => p.UserQuestionReceivers)
                .HasForeignKey(d => d.ReceiverId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("user_questions_receiver_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.UserQuestionUsers)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("user_questions_user_id_fkey");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
