using System.Text.Json.Serialization;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using EventBa.API.Auth;
using EventBa.API.Filters;
using EventBa.Services.Database.Context;
using EventBa.Services.Database;
using EventBa.Services.Mapper;
using EventBa.Services.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using Stripe;
using EventService = EventBa.Services.Services.EventService;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<EventBaDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<IEventReviewService, EventReviewService>();
builder.Services.AddTransient<IImageService, ImageService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddTransient<IRecommendedEventService, RecommendedEventService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<ITicketPurchaseService, TicketPurchaseService>();
builder.Services.AddTransient<ITicketService, TicketService>();
builder.Services.AddTransient<IUserQuestionService, UserQuestionService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRabbitMQProducer, RabbitMQProducer>();

builder.Services.AddHttpContextAccessor();


builder.Services.AddControllers(x => { x.Filters.Add<ErrorFilter>(); }).AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
});
;

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme()
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "basicAuth" }
            },
            new string[] { }
        }
    });
});

builder.Services.AddAutoMapper(typeof(IUserService));
builder.Services.AddAutoMapper(typeof(MappingProfile));

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddAuthorization();

//builder.WebHost.UseUrls("http://0.0.0.0:5187");

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<EventBaDbContext>();
    
    if (dataContext.Database.CanConnect())
    {
        dataContext.Database.Migrate();

        // Seed database if empty
        try
        {
            var hasData = dataContext.Set<Role>().Any();
            if (!hasData)
            {
                // Try multiple paths: Docker (/app/Data/seed.sql), local development (../Data/seed.sql), or current directory
                var possiblePaths = new[]
                {
                    Path.Combine("/app", "Data", "seed.sql"), // Docker
                    Path.Combine(Directory.GetCurrentDirectory(), "Data", "seed.sql"), // Local
                    Path.Combine(Directory.GetCurrentDirectory(), "..", "Data", "seed.sql") // Alternative local
                };
                
                string? seedScriptPath = possiblePaths.FirstOrDefault(System.IO.File.Exists);
                
                if (seedScriptPath != null && System.IO.File.Exists(seedScriptPath))
                {
                    var seedScript = System.IO.File.ReadAllText(seedScriptPath);
                    // Use NpgsqlConnection directly for executing the seed script
                    // ExecuteSqlRaw has issues with multi-statement SQL files
                    try
                    {
                        var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
                        using (var connection = new NpgsqlConnection(connectionString))
                        {
                            connection.Open();
                            using (var command = new NpgsqlCommand(seedScript, connection))
                            {
                                command.CommandTimeout = 120; // 2 minutes timeout for large scripts
                                command.ExecuteNonQuery();
                            }
                        }
                        Console.WriteLine("Database seeded successfully.");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error executing seed script: {ex.Message}");
                    }
                }
                else
                {
                    Console.WriteLine($"Warning: Seed script not found at {seedScriptPath}");
                }
            }
            else
            {
                Console.WriteLine("Database already contains data. Skipping seed.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error seeding database: {ex.Message}");
        }

        var recommenderService = scope.ServiceProvider.GetRequiredService<IRecommendedEventService>();
        try
        {
            recommenderService.TrainModel();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error training recommendation model: {ex.Message}");
        }
    }
}

app.Run();