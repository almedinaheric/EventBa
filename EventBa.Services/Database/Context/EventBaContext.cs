using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Database.Context;

public partial class EventBaContext : DbContext
{
    public EventBaContext()
    {
    }

    public EventBaContext(DbContextOptions<EventBaContext> options) : base(options)
    {
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=eventba_db;Username=username;Password=password");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}