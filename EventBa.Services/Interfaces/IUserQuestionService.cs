using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface IUserQuestionService : ICRUDService<UserQuestionResponseDto, UserQuestionSearchObject, UserQuestionInsertRequestDto,
    UserQuestionUpdateRequestDto>
{
    Task<List<UserQuestionResponseDto>> GetMyQuestions();
    Task<List<UserQuestionResponseDto>> GetQuestionsForMe();
}