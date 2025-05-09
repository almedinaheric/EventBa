using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using AutoMapper;
using EventBa.Model.Helpers;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace EventBa.Services.Services;

public class UserService :
    BaseCRUDService<UserResponseDto, User, UserSearchObject, UserInsertRequestDto, UserUpdateRequestDto>, IUserService
{
    private readonly EventBaDbContext _context;
    public IMapper _mapper { get; set; }
    
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserService(EventBaDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _httpContextAccessor = httpContextAccessor;
    }
    
    public override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObject? search = null)
    {
        return query
            .Include(u => u.ProfileImage)
            .Include(u => u.Role)
            .Include(u => u.Followings)
            .Include(u => u.Followers)
            .Include(u => u.Categories);
    }
    
    public override async Task BeforeInsert(User entity, UserInsertRequestDto insert)
    {
        entity.PasswordSalt = GenerateSalt();
        entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
    }

    public static string GenerateSalt()
    {
        var saltBytes = new byte[16];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(saltBytes);
        return Convert.ToBase64String(saltBytes);
    }
    
    public static string GenerateHash(string salt, string password)
    {
        var src = Convert.FromBase64String(salt);
        var bytes = Encoding.Unicode.GetBytes(password);
        var combined = new byte[src.Length + bytes.Length];

        Buffer.BlockCopy(src, 0, combined, 0, src.Length);
        Buffer.BlockCopy(bytes, 0, combined, src.Length, bytes.Length);

        using var sha256 = SHA256.Create();
        var hash = sha256.ComputeHash(combined);
        return Convert.ToBase64String(hash);
    }

    public async Task<UserResponseDto> Login(string email, string password)
    {
        var entity = await _context.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(x => x.Email == email);

        if (entity == null)
            throw new UserException("Invalid email or password.");


        var hash = GenerateHash(entity.PasswordSalt, password);

        if (hash != entity.PasswordHash)
            throw new UserException("Invalid email or password.");

        return _mapper.Map<UserResponseDto>(entity);
    }
    
    public async Task<UserResponseDto> GetUserAsync()
    {
        var userIdClaim = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;

        if (userIdClaim == null)
            throw new UserException("User is not authenticated");

        var user = await _context.Users
            .Include(u => u.Role)
            .Include(u => u.Followers)
            .Include(u => u.Followings)
            .Include(u => u.Categories)
            .Include(u => u.ProfileImage)
            .FirstOrDefaultAsync(u => u.Email.Equals(userIdClaim));
        
        if (user == null)
            throw new UserException("User not found");

        return _mapper.Map<UserResponseDto>(user);
    }
    
    public async Task<User> GetUserEntityAsync()
    {
        var userIdClaim = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;

        if (userIdClaim == null)
            throw new UserException("User is not authenticated");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email.Equals(userIdClaim));
        
        if (user == null)
            throw new UserException("User not found");

        return user;
    }
    
    public async Task<UserResponseDto> FollowUser(Guid userId)
    {
        var targetUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (targetUser == null)
            throw new UserException("The user you are trying to follow does not exist.");

        var currentUserEmail = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;
        if (string.IsNullOrWhiteSpace(currentUserEmail))
            throw new UserException("User is not authenticated.");

        var currentUser = await _context.Users
            .Include(u => u.Followings)
            .FirstOrDefaultAsync(u => u.Email == currentUserEmail);

        if (currentUser == null)
            throw new UserException("Authenticated user not found.");

        if (currentUser.Followings.Any(f => f.Id == userId))
            throw new UserException("You are already following this user.");

        currentUser.Followings.Add(targetUser);
        await _context.SaveChangesAsync();
        return _mapper.Map<UserResponseDto>(currentUser);
    }
    
    public async Task<UserResponseDto> UnfollowUser(Guid userId)
    {
        var targetUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (targetUser == null)
            throw new UserException("The user you are trying to unfollow does not exist.");

        var currentUserEmail = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;
        if (string.IsNullOrWhiteSpace(currentUserEmail))
            throw new UserException("User is not authenticated.");

        var currentUser = await _context.Users
            .Include(u => u.Followings)
            .FirstOrDefaultAsync(u => u.Email == currentUserEmail);

        if (currentUser == null)
            throw new UserException("Authenticated user not found.");

        var following = currentUser.Followings.FirstOrDefault(f => f.Id == userId);
        if (following == null)
            throw new UserException("You are not following this user.");

        currentUser.Followings.Remove(following);
        await _context.SaveChangesAsync();
        return _mapper.Map<UserResponseDto>(currentUser);
    }

}