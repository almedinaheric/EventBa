using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class CategoryController : BaseCRUDController<CategoryResponseDto, CategorySearchObject, CategoryInsertRequestDto
    ,
    CategoryUpdateRequestDto>
{
    private readonly ICategoryService _categoryService;

    public CategoryController(
        ILogger<BaseCRUDController<CategoryResponseDto, CategorySearchObject, CategoryInsertRequestDto,
            CategoryUpdateRequestDto>> logger, ICategoryService service) : base(logger, service)
    {
        _categoryService = service;
    }

    [HttpGet]
    [AllowAnonymous]
    public override async Task<PagedResult<CategoryResponseDto>> Get([FromQuery] CategorySearchObject search)
    {
        return await _service.Get(search);
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public override async Task<CategoryResponseDto> GetById(Guid id)
    {
        return await _service.GetById(id);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public override async Task<CategoryResponseDto> Insert([FromBody] CategoryInsertRequestDto insert)
    {
        return await _service.Insert(insert);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<CategoryResponseDto> Update(Guid id, [FromBody] CategoryUpdateRequestDto update)
    {
        return await _service.Update(id, update);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public override async Task<CategoryResponseDto> Delete(Guid id)
    {
        return await _service.Delete(id);
    }

    [HttpGet("getForReport")]
    [Authorize(Roles = "Admin")]
    public async Task<int> GetNumberOfItems()
    {
        return await _categoryService.GetNumberOfItems();
    }
}