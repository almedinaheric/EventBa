using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class RoleController : BaseCRUDController<RoleResponseDto, RoleSearchObject, RoleInsertRequestDto,
    RoleUpdateRequestDto>
{
    private readonly IRoleService _roleService;

    public RoleController(ILogger<BaseCRUDController<RoleResponseDto, RoleSearchObject, RoleInsertRequestDto,
        RoleUpdateRequestDto>> logger, IRoleService service) : base(logger, service)
    {
        _roleService = service;
    }
}