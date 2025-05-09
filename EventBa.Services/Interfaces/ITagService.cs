using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface ITagService : ICRUDService<TagResponseDto, TagSearchObject, TagInsertRequestDto,
    TagUpdateRequestDto>
{
}