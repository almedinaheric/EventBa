using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;

namespace EventBa.Services.Interfaces
{
	public interface INotificationService : IBaseService<NotificationResponse, NotificationSearchObject, NotificationRequest, NotificationRequest>
	{
	}
}
