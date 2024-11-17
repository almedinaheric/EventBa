using AutoMapper;
using EventBa.Model.Helpers;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.Extensions.Configuration;

namespace EventBa.Services.Services
{
    public class UserService : BaseService<UserResponse, User, UserSearchObject, UserRequest, UserRequest>, IUserService
    {
        public UserService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}