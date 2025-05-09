using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers;

[ApiController]
public class ImageController : BaseCRUDController<ImageResponseDto, ImageSearchObject, ImageInsertRequestDto,
    ImageUpdateRequestDto>
{
    private readonly IImageService _imageService;

    public ImageController(ILogger<BaseCRUDController<ImageResponseDto, ImageSearchObject, ImageInsertRequestDto,
        ImageUpdateRequestDto>> logger, IImageService service) : base(logger, service)
    {
        _imageService = service;
    }
}