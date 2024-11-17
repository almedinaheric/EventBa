using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services
{
    public class CategoryService : BaseService<CategoryResponse, Category, CategorySearchObject, CategoryRequest,
        CategoryRequest>, ICategoryService
    {
        public CategoryService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}