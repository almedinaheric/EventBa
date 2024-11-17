using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services
{
    public class NotificationService : BaseService<NotificationResponse, Notification, NotificationSearchObject,
        NotificationRequest, NotificationRequest>, INotificationService
    {
        public NotificationService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}