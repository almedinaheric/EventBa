using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class UserQuestionController : BaseCRUDController<UserQuestionResponseDto, UserQuestionSearchObject,
    UserQuestionInsertRequestDto, UserQuestionUpdateRequestDto>
{
    private readonly IUserQuestionService _userQuestionService;

    public UserQuestionController(
        ILogger<BaseCRUDController<UserQuestionResponseDto, UserQuestionSearchObject, UserQuestionInsertRequestDto,
            UserQuestionUpdateRequestDto>> logger, IUserQuestionService service) : base(logger, service)
    {
        _userQuestionService = service;
    }
}