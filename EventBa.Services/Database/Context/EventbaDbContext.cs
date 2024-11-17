using EventBa.Model.Enums;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Database.Context;

public partial class EventbaDbContext : DbContext
{
    public EventbaDbContext()
    {
    }

    public EventbaDbContext(DbContextOptions<EventbaDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Event> Events { get; set; }

    public virtual DbSet<Image> Images { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<SalesReport> SalesReports { get; set; }

    public virtual DbSet<Ticket> Tickets { get; set; }

    public virtual DbSet<TicketInstance> TicketInstances { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserNotification> UserNotifications { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseNpgsql("Name=ConnectionStrings:DefaultConnection");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .HasPostgresEnum("image_type", new[] { "PROFILE", "COVER", "EVENT" })
            .HasPostgresEnum("role_name", new[] { "ADMIN", "CUSTOMER" })
            .HasPostgresEnum("ticket_type", new[] { "VIP", "STANDARD", "FREE" });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("categories_pkey");

            entity.ToTable("categories");

            entity.Property(e => e.CategoryId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("category_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.Name)
                .HasMaxLength(255)
                .HasColumnName("name");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
        });

        modelBuilder.Entity<Event>(entity =>
        {
            entity.HasKey(e => e.EventId).HasName("events_pkey");

            entity.ToTable("events");

            entity.Property(e => e.EventId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("event_id");
            entity.Property(e => e.Address)
                .HasMaxLength(255)
                .HasColumnName("address");
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.EndDate).HasColumnName("end_date");
            entity.Property(e => e.EndTime).HasColumnName("end_time");
            entity.Property(e => e.Name)
                .HasMaxLength(255)
                .HasColumnName("name");
            entity.Property(e => e.OrganizerId).HasColumnName("organizer_id");
            entity.Property(e => e.StartDate).HasColumnName("start_date");
            entity.Property(e => e.StartTime).HasColumnName("start_time");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasColumnName("status");
            entity.Property(e => e.TicketsAvailable).HasColumnName("tickets_available");
            entity.Property(e => e.Type)
                .HasMaxLength(50)
                .HasColumnName("type");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");

            entity.HasOne(d => d.Category).WithMany(p => p.Events)
                .HasForeignKey(d => d.CategoryId)
                .HasConstraintName("events_category_id_fkey");

            entity.HasOne(d => d.Organizer).WithMany(p => p.Events)
                .HasForeignKey(d => d.OrganizerId)
                .HasConstraintName("events_organizer_id_fkey");
        });

        modelBuilder.Entity<Image>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("images_pkey");

            entity.ToTable("images");

            entity.Property(e => e.ImageId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("image_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.ImageData).HasColumnName("image_data");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ImageType)
                .HasConversion(
                    v => v.ToString(),
                    v => (ImageType)Enum.Parse(typeof(ImageType), v))
                .HasColumnName("image_type")
                .HasColumnType("text");

            entity.HasOne(d => d.Event).WithMany(p => p.Images)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("images_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.Images)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("images_user_id_fkey");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.NotificationId).HasName("notifications_pkey");

            entity.ToTable("notifications");

            entity.Property(e => e.NotificationId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("notification_id");
            entity.Property(e => e.Content).HasColumnName("content");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.SenderId).HasColumnName("sender_id");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasColumnName("status");
            entity.Property(e => e.Title)
                .HasMaxLength(255)
                .HasColumnName("title");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");

            entity.HasOne(d => d.Sender).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.SenderId)
                .HasConstraintName("notifications_sender_id_fkey");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.ReviewId).HasName("reviews_pkey");

            entity.ToTable("reviews");

            entity.Property(e => e.ReviewId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("review_id");
            entity.Property(e => e.Comment).HasColumnName("comment");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.Rating).HasColumnName("rating");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Event).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("reviews_event_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("reviews_user_id_fkey");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("roles_pkey");

            entity.ToTable("roles");

            entity.Property(e => e.RoleId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("role_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.RoleName)
                .HasConversion(
                    v => v.ToString(),
                    v => (RoleName)Enum.Parse(typeof(RoleName), v))
                .HasColumnName("role_name")
                .HasColumnType("text");
        });

        modelBuilder.Entity<SalesReport>(entity =>
        {
            entity.HasKey(e => e.ReportId).HasName("sales_reports_pkey");

            entity.ToTable("sales_reports");

            entity.Property(e => e.ReportId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("report_id");
            entity.Property(e => e.AttendanceCount).HasColumnName("attendance_count");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.TicketsSold).HasColumnName("tickets_sold");
            entity.Property(e => e.TotalRevenue)
                .HasPrecision(10, 2)
                .HasColumnName("total_revenue");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");

            entity.HasOne(d => d.Event).WithMany(p => p.SalesReports)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("sales_reports_event_id_fkey");
        });

        modelBuilder.Entity<Ticket>(entity =>
        {
            entity.HasIndex(t => new { t.EventId, t.TicketType })
                .HasName("tickets_event_id_ticket_type_key");

            entity.HasKey(e => e.TicketId).HasName("tickets_pkey");

            entity.ToTable("tickets");

            entity.Property(e => e.TicketId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("ticket_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.EventId).HasColumnName("event_id");
            entity.Property(e => e.Price)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("0")
                .HasColumnName("price");
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.TicketsSold)
                .HasDefaultValue(0)
                .HasColumnName("tickets_sold");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.TicketType)
                .HasConversion(
                    v => v.ToString(),
                    v => (TicketType)Enum.Parse(typeof(TicketType), v))
                .HasColumnName("ticket_type")  // Correct the column name to match your database
                .HasColumnType("text");  // Use text for storing the enum as string

            entity.HasOne(d => d.Event).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.EventId)
                .HasConstraintName("tickets_event_id_fkey");
        });


        modelBuilder.Entity<TicketInstance>(entity =>
        {
            entity.HasKey(e => e.TicketInstanceId).HasName("ticket_instances_pkey");

            entity.ToTable("ticket_instances");

            entity.Property(e => e.TicketInstanceId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("ticket_instance_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.QrCode)
                .HasMaxLength(255)
                .HasColumnName("qr_code");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("'PURCHASED'::character varying")
                .HasColumnName("status");
            entity.Property(e => e.TicketId).HasColumnName("ticket_id");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Ticket).WithMany(p => p.TicketInstances)
                .HasForeignKey(d => d.TicketId)
                .HasConstraintName("ticket_instances_ticket_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.TicketInstances)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("ticket_instances_user_id_fkey");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("users_pkey");

            entity.ToTable("users");

            entity.HasIndex(e => e.Email, "users_email_key").IsUnique();

            entity.Property(e => e.UserId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("user_id");
            entity.Property(e => e.Bio).HasColumnName("bio");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.Email)
                .HasMaxLength(255)
                .HasColumnName("email");
            entity.Property(e => e.FullName)
                .HasMaxLength(255)
                .HasColumnName("full_name");
            entity.Property(e => e.PasswordHash)
                .HasMaxLength(255)
                .HasColumnName("password_hash");
            entity.Property(e => e.PasswordSalt)
                .HasMaxLength(255)
                .HasColumnName("password_salt");
            entity.Property(e => e.RoleId).HasColumnName("role_id");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("users_role_id_fkey");

            entity.HasMany(d => d.Categories).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "UserInterest",
                    r => r.HasOne<Category>().WithMany()
                        .HasForeignKey("CategoryId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("user_interests_category_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("user_interests_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "CategoryId").HasName("user_interests_pkey");
                        j.ToTable("user_interests");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("CategoryId").HasColumnName("category_id");
                    });

            entity.HasMany(d => d.Events1).WithMany(p => p.UsersNavigation)
                .UsingEntity<Dictionary<string, object>>(
                    "Recommendation",
                    r => r.HasOne<Event>().WithMany()
                        .HasForeignKey("EventId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("recommendations_event_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("recommendations_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "EventId").HasName("recommendations_pkey");
                        j.ToTable("recommendations");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("EventId").HasColumnName("event_id");
                    });

            entity.HasMany(d => d.EventsNavigation).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "Favorite",
                    r => r.HasOne<Event>().WithMany()
                        .HasForeignKey("EventId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("favorites_event_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("favorites_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "EventId").HasName("favorites_pkey");
                        j.ToTable("favorites");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("EventId").HasColumnName("event_id");
                    });

            entity.HasMany(d => d.FollowerUsers).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "Follower",
                    r => r.HasOne<User>().WithMany()
                        .HasForeignKey("FollowerUserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("followers_follower_user_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("followers_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "FollowerUserId").HasName("followers_pkey");
                        j.ToTable("followers");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("FollowerUserId").HasColumnName("follower_user_id");
                    });

            entity.HasMany(d => d.Users).WithMany(p => p.FollowerUsers)
                .UsingEntity<Dictionary<string, object>>(
                    "Follower",
                    r => r.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("followers_user_id_fkey"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("FollowerUserId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("followers_follower_user_id_fkey"),
                    j =>
                    {
                        j.HasKey("UserId", "FollowerUserId").HasName("followers_pkey");
                        j.ToTable("followers");
                        j.IndexerProperty<Guid>("UserId").HasColumnName("user_id");
                        j.IndexerProperty<Guid>("FollowerUserId").HasColumnName("follower_user_id");
                    });
        });

        modelBuilder.Entity<UserNotification>(entity =>
        {
            entity.HasKey(e => e.UserNotificationId).HasName("user_notifications_pkey");

            entity.ToTable("user_notifications");

            entity.Property(e => e.UserNotificationId)
                .HasDefaultValueSql("gen_random_uuid()")
                .HasColumnName("user_notification_id");
            entity.Property(e => e.Created)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("created");
            entity.Property(e => e.NotificationId).HasColumnName("notification_id");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValueSql("'UNREAD'::character varying")
                .HasColumnName("status");
            entity.Property(e => e.Updated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("updated");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.Notification).WithMany(p => p.UserNotifications)
                .HasForeignKey(d => d.NotificationId)
                .HasConstraintName("user_notifications_notification_id_fkey");

            entity.HasOne(d => d.User).WithMany(p => p.UserNotifications)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("user_notifications_user_id_fkey");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}