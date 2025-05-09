using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class TagController : BaseCRUDController<TagResponseDto, TagSearchObject, TagInsertRequestDto,
    TagUpdateRequestDto>
{
    private readonly ITagService _tagService;

    public TagController(ILogger<BaseCRUDController<TagResponseDto, TagSearchObject, TagInsertRequestDto,
        TagUpdateRequestDto>> logger, ITagService service) : base(logger, service)
    {
        _tagService = service;
    }
}