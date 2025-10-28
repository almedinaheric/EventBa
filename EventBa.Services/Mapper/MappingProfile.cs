using AutoMapper;
using EventBa.Model.Enums;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Services.Database;

namespace EventBa.Services.Mapper;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<int?, int>().ConvertUsing((src, dest) => src ?? dest);
        CreateMap<string?, string>().ConvertUsing((src, dest) => src ?? dest);
        CreateMap<double?, double>().ConvertUsing((src, dest) => src ?? dest);
        CreateMap<Guid?, Guid>().ConvertUsing((src, dest) => src ?? dest);

        // ---------------------
        // User
        // ---------------------
        CreateMap<User, UserResponseDto>()
            .ForMember(dest => dest.ProfileImage, opt => opt.MapFrom(src => src.ProfileImage))
            .ForMember(dest => dest.Role, opt => opt.MapFrom(src => src.Role))
            .ForMember(dest => dest.Followers, opt => opt.MapFrom(src => src.Followers))
            .ForMember(dest => dest.Following, opt => opt.MapFrom(src => src.Followings))
            .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Categories))
            .ForMember(dest => dest.FavoriteEvents, opt => opt.MapFrom(src => src.FavoriteEvents))
            .ReverseMap();
        CreateMap<User, BasicUserResponseDto>();
        CreateMap<UserInsertRequestDto, User>();
        CreateMap<UserUpdateRequestDto, User>();

        // ---------------------
        // Event
        // ---------------------
        CreateMap<Event, EventResponseDto>()
            .ForMember(dest => dest.CoverImage, opt => opt.MapFrom(src => src.CoverImage))
            .ForMember(dest => dest.GalleryImages, opt => opt.MapFrom(src => src.EventGalleryImages))
            .ForMember(dest => dest.Category, opt => opt.MapFrom(src => src.Category))
            .ForMember(dest => dest.IsPaid, opt => opt.MapFrom(src => 
                src.Tickets != null && src.Tickets.Any() && 
                src.Tickets.Any(t => t.TicketType != TicketType.Free && t.Price > 0)))
            .ReverseMap();
        CreateMap<Event, BasicEventResponseDto>()
            .ForMember(dest => dest.IsPaid, opt => opt.MapFrom(src => 
                src.Tickets != null && src.Tickets.Any() && 
                src.Tickets.Any(t => t.TicketType != TicketType.Free && t.Price > 0)));
        CreateMap<EventInsertRequestDto, Event>();
        CreateMap<EventUpdateRequestDto, Event>();

        // ---------------------
        // EventGalleryImage
        // ---------------------
        CreateMap<EventGalleryImage, EventGalleryImageResponseDto>().ReverseMap();

        // ---------------------
        // Ticket
        // ---------------------
        CreateMap<Ticket, TicketResponseDto>().ReverseMap();
        CreateMap<TicketInsertRequestDto, Ticket>();
        CreateMap<TicketUpdateRequestDto, Ticket>();

        // ---------------------
        // Payment
        // ---------------------
        CreateMap<Payment, PaymentResponseDto>().ReverseMap();
        CreateMap<PaymentInsertRequestDto, Payment>();
        CreateMap<PaymentUpdateRequestDto, Payment>();

        // ---------------------
        // EventReview
        // ---------------------
        CreateMap<EventReview, EventReviewResponseDto>().ReverseMap();
        CreateMap<EventReviewInsertRequestDto, EventReview>();
        CreateMap<EventReviewUpdateRequestDto, EventReview>();

        // ---------------------
        // Notification
        // ---------------------
        CreateMap<Notification, NotificationResponseDto>().ReverseMap();
        CreateMap<NotificationInsertRequestDto, Notification>();
        CreateMap<NotificationUpdateRequestDto, Notification>();

        // ---------------------
        // Category
        // ---------------------
        CreateMap<Category, CategoryResponseDto>().ReverseMap();
        CreateMap<CategoryInsertRequestDto, Category>();
        CreateMap<CategoryUpdateRequestDto, Category>();

        // ---------------------
        // Image
        // ---------------------
        CreateMap<Image, ImageResponseDto>().ReverseMap();
        CreateMap<ImageInsertRequestDto, Image>();
        CreateMap<ImageUpdateRequestDto, Image>();

        // ---------------------
        // Role
        // ---------------------
        CreateMap<Role, RoleResponseDto>().ReverseMap();
        CreateMap<RoleInsertRequestDto, Role>();
        CreateMap<RoleUpdateRequestDto, Role>();

        // ---------------------
        // TicketPurchase
        // ---------------------
        CreateMap<TicketPurchase, TicketPurchaseResponseDto>().ReverseMap();
        CreateMap<TicketPurchaseInsertRequestDto, TicketPurchase>();
        CreateMap<TicketPurchaseUpdateRequestDto, TicketPurchase>();

        // ---------------------
        // UserQuestion
        // ---------------------
        CreateMap<UserQuestion, UserQuestionResponseDto>().ReverseMap();
        CreateMap<UserQuestionInsertRequestDto, UserQuestion>();
        CreateMap<UserQuestionUpdateRequestDto, UserQuestion>();
    }
}
