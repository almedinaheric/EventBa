using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
[Route("[controller]")]
public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : class
{
    protected readonly IService<T, TSearch> _service;
    protected readonly ILogger<BaseController<T, TSearch>> _logger;

    public BaseController(ILogger<BaseController<T, TSearch>> logger, IService<T, TSearch> service)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet()]
    [Authorize]
    public virtual async Task<PagedResult<T>> Get([FromQuery] TSearch search)
    {
        return await _service.Get(search);
    }

    [HttpGet("{id}")]
    [Authorize]
    public virtual async Task<T> GetById(Guid id)
    {
        return await _service.GetById(id);
    }
}