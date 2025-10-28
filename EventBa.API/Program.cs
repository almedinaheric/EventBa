using System.Text.Json.Serialization;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using EventBa.API.Auth;
using EventBa.API.Filters;
using EventBa.Services.Database.Context;
using EventBa.Services.Mapper;
using EventBa.Services.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using Stripe;
using EventService = EventBa.Services.Services.EventService;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<EventBaDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Stripe
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
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// ✅ This order matters
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();