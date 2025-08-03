using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class UserQuestionService : BaseCRUDService<UserQuestionResponseDto, UserQuestion, UserQuestionSearchObject,
    UserQuestionInsertRequestDto, UserQuestionUpdateRequestDto>, IUserQuestionService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public UserQuestionService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(UserQuestion entity, UserQuestionInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
    }

    public override IQueryable<UserQuestion> AddInclude(IQueryable<UserQuestion> query, UserQuestionSearchObject? search = null)
    {
        query = query.Include(x => x.User)
                    .Include(x => x.Receiver);
        return query;
    }

    public async Task<List<UserQuestionResponseDto>> GetMyQuestions()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.Receiver)
            .Where(x => x.UserId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }

    public async Task<List<UserQuestionResponseDto>> GetQuestionsForMe()
    {
        var currentUser = await _userService.GetUserEntityAsync();
        var questions = await _context.UserQuestions
            .Include(x => x.User)
            .Where(x => x.ReceiverId == currentUser.Id)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();

        return _mapper.Map<List<UserQuestionResponseDto>>(questions);
    }
}