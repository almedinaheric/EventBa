using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;

namespace EventBa.Services.Interfaces;

public interface ICategoryService : ICRUDService<CategoryResponseDto, CategorySearchObject, CategoryInsertRequestDto,
    CategoryUpdateRequestDto>
{
    Task<int> GetNumberOfItems();
}