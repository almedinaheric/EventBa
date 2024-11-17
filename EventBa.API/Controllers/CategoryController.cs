using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class
        CategoryController : BaseController<CategoryResponse, CategorySearchObject, CategoryRequest, CategoryRequest>
    {
        public CategoryController(
            ILogger<BaseController<CategoryResponse, CategorySearchObject, CategoryRequest, CategoryRequest>> logger,
            ICategoryService service) : base(logger, service)
        {
        }
    }
}