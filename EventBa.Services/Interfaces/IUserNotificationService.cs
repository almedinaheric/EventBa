﻿using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;

namespace EventBa.Services.Interfaces
{
	public interface IUserNotificationService : IBaseService<UserNotificationResponse, UserNotificationSearchObject, UserNotificationRequest, UserNotificationRequest>
	{
	}
}