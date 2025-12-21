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
            .Include(u => u.Categories)
            .Include(u => u.Events)
            .Include(u => u.FavoriteEvents);
    }
    
    public override IQueryable<User> AddFilter(IQueryable<User> query, UserSearchObject? search = null)
    {
        // Only exclude Admin users if explicitly requested
        if (search?.ExcludeAdmins == true)
        {
            query = query.Where(u => u.Role.Name != Model.Enums.RoleName.Admin);
        }
        
        if (!string.IsNullOrWhiteSpace(search?.SearchTerm))
        {
            var searchTerm = search.SearchTerm.ToLower();
            query = query.Where(u => 
                u.FirstName.ToLower().Contains(searchTerm) || 
                u.LastName.ToLower().Contains(searchTerm) ||
                u.Email.ToLower().Contains(searchTerm)
            );
        }
        
        if (!string.IsNullOrWhiteSpace(search?.FirstName))
        {
            query = query.Where(u => u.FirstName.ToLower().Contains(search.FirstName.ToLower()));
        }
        
        if (!string.IsNullOrWhiteSpace(search?.LastName))
        {
            query = query.Where(u => u.LastName.ToLower().Contains(search.LastName.ToLower()));
        }
        
        if (!string.IsNullOrWhiteSpace(search?.Email))
        {
            query = query.Where(u => u.Email.ToLower().Contains(search.Email.ToLower()));
        }
        
        return query;
    }
    
    public override async Task BeforeInsert(User entity, UserInsertRequestDto insert)
    {
        Console.WriteLine($"BeforeInsert called for user: {insert.Email}");
        
        entity.PasswordSalt = GenerateSalt();
        entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
        
        Console.WriteLine($"Password hashed successfully for: {insert.Email}");
        
        // Handle category relationships
        if (insert.InterestCategoryIds != null && insert.InterestCategoryIds.Any())
        {
            Console.WriteLine($"Processing {insert.InterestCategoryIds.Count} categories for user: {insert.Email}");
            var categories = await _context.Categories
                .Where(c => insert.InterestCategoryIds.Contains(c.Id))
                .ToListAsync();
            
            Console.WriteLine($"Found {categories.Count} categories in database");
            
            foreach (var category in categories)
            {
                entity.Categories.Add(category);
            }
        }
        
        Console.WriteLine($"BeforeInsert completed for user: {insert.Email}");
    }

    public override async Task<UserResponseDto> Update(Guid id, UserUpdateRequestDto update)
    {
        var set = _context.Set<User>();
        var entity = await set
            .Include(u => u.ProfileImage)
            .FirstOrDefaultAsync(u => u.Id == id);
        
        if (entity == null)
            throw new UserException("User not found");
        
        // Store old profile image ID before mapping (since mapper will overwrite it)
        var oldProfileImageId = entity.ProfileImageId;
        
        // Map the update to the entity
        _mapper.Map(update, entity);
        
        // Handle profile image replacement - only delete old profile image if it's being replaced with a different one
        if (update.ProfileImageId.HasValue && oldProfileImageId.HasValue && 
            update.ProfileImageId.Value != oldProfileImageId.Value)
        {
            // Old profile image is being replaced with a new one, delete the old one
            var oldProfileImage = await _context.Images.FindAsync(oldProfileImageId.Value);
            if (oldProfileImage != null)
            {
                _context.Images.Remove(oldProfileImage);
            }
        }
        else if (update.ProfileImageId.HasValue && update.ProfileImageId.Value == oldProfileImageId)
        {
            // Same profile image ID - no change needed, just keep it
        }
        else if (!update.ProfileImageId.HasValue && oldProfileImageId.HasValue)
        {
            // No profile image ID in update but one exists - preserve the existing one
            entity.ProfileImageId = oldProfileImageId;
        }
        
        // Handle category interests
        await BeforeUpdate(entity, update);
        
        await _context.SaveChangesAsync();
        return _mapper.Map<UserResponseDto>(entity);
    }

    public override async Task BeforeUpdate(User entity, UserUpdateRequestDto update)
    {
        var newCategoryIds = update.InterestCategoryIds ?? new List<Guid>();

        var existingUserInterests = _context.Entry(entity)
            .Collection(u => u.Categories)
            .Query()
            .ToList();

        foreach (var category in existingUserInterests)
        {
            entity.Categories.Remove(category);
        }

        if (newCategoryIds.Any())
        {
            var newCategories = await _context.Categories
                .Where(c => newCategoryIds.Contains(c.Id))
                .ToListAsync();

            foreach (var category in newCategories)
            {
                if (entity.Categories.All(c => c.Id != category.Id))
                {
                    entity.Categories.Add(category);
                }
            }
        }
    }

    public override async Task<UserResponseDto> Insert(UserInsertRequestDto insert)
    {
        Console.WriteLine($"UserService.Insert called for: {insert.Email}");
    
        try
        {
            var result = await base.Insert(insert);
            var entityWithIncludes = await AddInclude(_context.Set<User>().Where(u => u.Id == Guid.Parse(result.Id.ToString())))
                .FirstOrDefaultAsync();
            
            if (entityWithIncludes != null)
            {
                result = _mapper.Map<UserResponseDto>(entityWithIncludes);
            }
        
            Console.WriteLine($"UserService.Insert completed successfully for: {insert.Email}");
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"UserService.Insert failed for {insert.Email}: {ex.Message}");
            throw;
        }
    }
    
    public override async Task<UserResponseDto> GetById(Guid id)
    {
        var query = _context.Users.AsQueryable();
        query = AddInclude(query);
        var entity = await query.FirstOrDefaultAsync(u => u.Id == id);

        if (entity == null)
            throw new UserException("User not found");

        return _mapper.Map<UserResponseDto>(entity);
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
        Console.WriteLine("GetUserAsync method called");

        var userIdClaim = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;

        if (userIdClaim == null)
            throw new UserException("User is not authenticated");

        var query = _context.Users.AsQueryable();
        query = AddInclude(query);
        var user = await query.FirstOrDefaultAsync(u => u.Email.Equals(userIdClaim));
        
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
    
    public async Task ChangePasswordAsync(ChangePasswordRequestDto request)
    {
        var userEmail = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.Email)?.Value;

        if (string.IsNullOrWhiteSpace(userEmail))
            throw new UserException("User is not authenticated.");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);

        if (user == null)
            throw new UserException("User not found.");

        var currentHash = GenerateHash(user.PasswordSalt, request.CurrentPassword);

        if (currentHash != user.PasswordHash)
            throw new UserException("Current password is incorrect.");

        user.PasswordSalt = GenerateSalt();
        user.PasswordHash = GenerateHash(user.PasswordSalt, request.NewPassword);

        await _context.SaveChangesAsync();
    }
}