using EventBa.Model.Helpers;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<T, TSearch, TInsert, TUpdate> : ControllerBase where T : class
        where TSearch : class
        where TInsert : class
        where TUpdate : class
    {
        private readonly IBaseService<T, TSearch, TInsert, TUpdate> _service;
        private readonly ILogger<BaseController<T, TSearch, TInsert, TUpdate>> _logger;

        public BaseController(ILogger<BaseController<T, TSearch, TInsert, TUpdate>> logger,
            IBaseService<T, TSearch, TInsert, TUpdate> service)
        {
            _logger = logger;
            _service = service;
        }

        // Insert method
        [HttpPost()]
        public async Task<T> Insert([FromBody] TInsert insert)
        {
            return await _service.Insert(insert);
        }

        // Get method to retrieve data based on filters
        [HttpGet()]
        public async Task<IEnumerable<T>> Get([FromQuery] TSearch? search = null)
        {
            return await _service.Get(search);
        }

        // GetById method to retrieve a single entity by ID
        [HttpGet("{id}")]
        public async Task<T> GetById(int id)
        {
            return await _service.GetById(id);
        }

        // GetPage method for paginated results
        [HttpGet("GetPage")]
        public async Task<PagedResult<T>> GetPage([FromQuery] TSearch? search = null)
        {
            return await _service.GetPage(search);
        }

        // Update method
        [HttpPut("{id}")]
        public async Task<T> Update(int id, [FromBody] TUpdate update)
        {
            return await _service.Update(id, update);
        }

        // Delete method to remove an entity by ID
        [HttpDelete("{id}")]
        public async Task<T> Delete(int id)
        {
            return await _service.Delete(id);
        }
    }
}