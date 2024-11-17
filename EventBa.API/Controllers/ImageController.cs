using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class ImageController : BaseController<ImageResponse, ImageSearchObject, ImageRequest, ImageRequest>
    {
        public ImageController(
            ILogger<BaseController<ImageResponse, ImageSearchObject, ImageRequest, ImageRequest>> logger,
            IImageService service) : base(logger, service)
        {
        }
    }
}