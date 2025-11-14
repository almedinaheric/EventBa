using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class ImageService : BaseCRUDService<ImageResponseDto, Image, ImageSearchObject,
    ImageInsertRequestDto, ImageUpdateRequestDto>, IImageService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    private readonly IUserService _userService;

    public ImageService(EventBaDbContext context, IMapper mapper, IUserService userService) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _userService = userService;
    }

    public override async Task BeforeInsert(Image entity, ImageInsertRequestDto insert)
    {
        entity.User = await _userService.GetUserEntityAsync();
        entity.ImageData = insert.Data;
        entity.FileName = $"image_{Guid.NewGuid()}.jpg";
        entity.FileSize = insert.Data?.Length;
        entity.ImageType = Model.Enums.ImageType.EventCover; // Default, can be changed later
    }

    public override IQueryable<Image> AddInclude(IQueryable<Image> query, ImageSearchObject? search = null)
    {
        query = query.Include(x => x.User);
        return query;
    }

    public async Task<List<ImageResponseDto>> GetImagesForEvent(Guid eventId)
    {
        var images = await _context.EventGalleryImages
            .Include(x => x.Image)
            .Where(x => x.EventId == eventId)
            .Select(x => x.Image)
            .ToListAsync();

        return _mapper.Map<List<ImageResponseDto>>(images);
    }
}