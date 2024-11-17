using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Services.Database;

namespace TrackIt.Services
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<int?, int>().ConvertUsing((src, dest) => src ?? dest);
            CreateMap<string?, string>().ConvertUsing((src, dest) => src ?? dest);
            CreateMap<double?, double>().ConvertUsing((src, dest) => src ?? dest);

            CreateMap<Category, CategoryResponse>();
            CreateMap<CategoryRequest, Category>();
            CreateMap<CategoryRequest, Category>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Event, EventResponse>();
            CreateMap<EventRequest, Event>();
            CreateMap<EventRequest, Event>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Notification, NotificationResponse>();
            CreateMap<NotificationRequest, Notification>();
            CreateMap<NotificationRequest, Notification>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Role, RoleResponse>();
            CreateMap<RoleRequest, Role>();
            CreateMap<RoleRequest, Role>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Ticket, TicketResponse>();
            CreateMap<TicketRequest, Ticket>();
            CreateMap<TicketRequest, Ticket>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<User, UserResponse>();
            CreateMap<UserRequest, User>();
            CreateMap<UserRequest, User>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Image, ImageResponse>();
            CreateMap<ImageRequest, Image>();
            CreateMap<ImageRequest, Image>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Review, ReviewResponse>();
            CreateMap<ReviewRequest, Review>();
            CreateMap<ReviewRequest, Review>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<SalesReport, SalesReportResponse>();
            CreateMap<SalesReportRequest, SalesReport>();
            CreateMap<SalesReportRequest, SalesReport>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<TicketInstance, TicketInstanceResponse>();
            CreateMap<TicketInstanceRequest, TicketInstance>();
            CreateMap<TicketInstanceRequest, TicketInstance>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<UserNotification, UserNotificationResponse>();
            CreateMap<UserNotificationRequest, UserNotification>();
            CreateMap<UserNotificationRequest, UserNotification>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}