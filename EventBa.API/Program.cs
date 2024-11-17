using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using EventBa.Services.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<IImageService, ImageService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<ISalesReportService, SalesReportService>();
builder.Services.AddTransient<ITicketInstanceService, TicketInstanceService>();
builder.Services.AddTransient<ITicketService, TicketService>();
builder.Services.AddTransient<IUserNotificationService, UserNotificationService>();
builder.Services.AddTransient<IUserService, UserService>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<EventbaDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddAutoMapper(typeof(IUserService));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();