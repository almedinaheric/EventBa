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
    private readonly IRabbitMQProducer _rabbitMQProducer;

    public UserService(EventBaDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor,
        IRabbitMQProducer rabbitMQProducer) : base(context, mapper)
    {
        _context = context;
        _mapper = mapper;
        _httpContextAccessor = httpContextAccessor;
        _rabbitMQProducer = rabbitMQProducer;
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
        if (search?.ExcludeAdmins == true) query = query.Where(u => u.Role.Name != Model.Enums.RoleName.Admin);

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
            query = query.Where(u => u.FirstName.ToLower().Contains(search.FirstName.ToLower()));

        if (!string.IsNullOrWhiteSpace(search?.LastName))
            query = query.Where(u => u.LastName.ToLower().Contains(search.LastName.ToLower()));

        if (!string.IsNullOrWhiteSpace(search?.Email))
            query = query.Where(u => u.Email.ToLower().Contains(search.Email.ToLower()));

        return query;
    }

    public override async Task BeforeInsert(User entity, UserInsertRequestDto insert)
    {
        entity.PasswordSalt = GenerateSalt();
        entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);

        if (insert.InterestCategoryIds != null && insert.InterestCategoryIds.Any())
        {
            var categories = await _context.Categories
                .Where(c => insert.InterestCategoryIds.Contains(c.Id))
                .ToListAsync();

            foreach (var category in categories) entity.Categories.Add(category);
        }
    }

    public override async Task<UserResponseDto> Update(Guid id, UserUpdateRequestDto update)
    {
        var set = _context.Set<User>();
        var entity = await set
            .Include(u => u.ProfileImage)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (entity == null)
            throw new UserException("User not found");

        var oldProfileImageId = entity.ProfileImageId;

        _mapper.Map(update, entity);

        if (update.ProfileImageId.HasValue && oldProfileImageId.HasValue &&
            update.ProfileImageId.Value != oldProfileImageId.Value)
        {
            var oldProfileImage = await _context.Images.FindAsync(oldProfileImageId.Value);
            if (oldProfileImage != null) _context.Images.Remove(oldProfileImage);
        }
        else if (!update.ProfileImageId.HasValue && oldProfileImageId.HasValue)
        {
            entity.ProfileImageId = oldProfileImageId;
        }

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

        foreach (var category in existingUserInterests) entity.Categories.Remove(category);

        if (newCategoryIds.Any())
        {
            var newCategories = await _context.Categories
                .Where(c => newCategoryIds.Contains(c.Id))
                .ToListAsync();

            foreach (var category in newCategories)
                if (entity.Categories.All(c => c.Id != category.Id))
                    entity.Categories.Add(category);
        }
    }

    public override async Task<UserResponseDto> Insert(UserInsertRequestDto insert)
    {
        try
        {
            var result = await base.Insert(insert);
            var entityWithIncludes =
                await AddInclude(_context.Set<User>().Where(u => u.Id == Guid.Parse(result.Id.ToString())))
                    .FirstOrDefaultAsync();

            if (entityWithIncludes != null) result = _mapper.Map<UserResponseDto>(entityWithIncludes);

            return result;
        }
        catch (Exception ex)
        {
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

    public async Task ForgotPasswordAsync(string email)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

        if (user == null) return;

        var random = new Random();
        var code = random.Next(100000, 999999).ToString();
        user.PasswordResetCode = code;

        user.PasswordResetCodeExpiry = DateTime.UtcNow.AddHours(24);

        await _context.SaveChangesAsync();

        try
        {
            var emailModel = new EmailModel
            {
                Sender = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "noreply@eventba.com",
                Recipient = user.Email,
                Subject = "Password Reset Code",
                Content = $@"
Hello {user.FirstName} {user.LastName},

You requested to reset your password. Please use the following code to reset your password:

{code}

This code will expire in 24 hours.

If you did not request this password reset, please ignore this email.

Best regards,
EventBa Team
"
            };

            _rabbitMQProducer.SendMessage(emailModel);
        }
        catch (Exception ex)
        {
        }
    }

    public async Task<bool> ValidateResetCodeAsync(string email, string code)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

        if (user == null)
            return false;

        if (user.PasswordResetCodeExpiry == null || user.PasswordResetCodeExpiry < DateTime.UtcNow)
            return false;

        if (user.PasswordResetCode != null && user.PasswordResetCode == code) return true;

        return false;
    }

    public async Task ResetPasswordAsync(string email, string code, string newPassword)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

        if (user == null)
            throw new UserException("Invalid reset code.");

        if (user.PasswordResetCodeExpiry == null || user.PasswordResetCodeExpiry < DateTime.UtcNow)
            throw new UserException("Reset code has expired. Please request a new one.");

        if (string.IsNullOrWhiteSpace(code) || user.PasswordResetCode == null || user.PasswordResetCode != code)
            throw new UserException("Invalid reset code.");

        user.PasswordSalt = GenerateSalt();
        user.PasswordHash = GenerateHash(user.PasswordSalt, newPassword);
        user.PasswordResetCode = null;
        user.PasswordResetCodeExpiry = null;

        await _context.SaveChangesAsync();

        try
        {
            var emailModel = new EmailModel
            {
                Sender = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "noreply@eventba.com",
                Recipient = user.Email,
                Subject = "Password Reset Successful",
                Content = $@"
Hello {user.FirstName} {user.LastName},

Your password has been successfully reset.

If you did not perform this action, please contact support immediately.

Best regards,
EventBa Team
"
            };

            _rabbitMQProducer.SendMessage(emailModel);
        }
        catch (Exception ex)
        {
        }
    }
}