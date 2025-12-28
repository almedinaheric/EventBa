using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace EventBa.API.Auth;

public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly IUserService _userService;
    private readonly IRecommendedEventService _recommendedEventService;

    public BasicAuthenticationHandler(
        IUserService userService, 
        IRecommendedEventService recommendedEventService,
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger, 
        UrlEncoder encoder, 
        ISystemClock clock) : base(options, logger, encoder, clock)
    {
        _userService = userService;
        _recommendedEventService = recommendedEventService;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!Request.Headers.TryGetValue("Authorization", out var authHeaderValue))
        {
            return AuthenticateResult.Fail("Missing authorization header");
        }

        if (!AuthenticationHeaderValue.TryParse(authHeaderValue, out var authHeader) ||
            !authHeader.Scheme.Equals("Basic", StringComparison.OrdinalIgnoreCase))
        {
            return AuthenticateResult.Fail("Invalid authorization header");
        }

        var credentials = DecodeCredentials(authHeader.Parameter);
        if (credentials == null)
        {
            return AuthenticateResult.Fail("Invalid authorization header");
        }

        var (email, password) = credentials.Value;
        var user = await _userService.Login(email, password);

        if (user == null)
        {
            return AuthenticateResult.Fail("Incorrect email or password");
        }


        var claims = CreateClaims(user);
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);

        return AuthenticateResult.Success(ticket);
    }

    private static (string email, string password)? DecodeCredentials(string? parameter)
    {
        if (string.IsNullOrWhiteSpace(parameter))
            return null;

        try
        {
            var bytes = Convert.FromBase64String(parameter);
            var decoded = Encoding.UTF8.GetString(bytes);
            var parts = decoded.Split(':', 2);
            return parts.Length == 2 ? (parts[0], parts[1]) : null;
        }
        catch
        {
            return null;
        }
    }

    private static IEnumerable<Claim> CreateClaims(dynamic user)
    {
        return new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.GivenName, user.FirstName),
            new Claim(ClaimTypes.Surname, user.LastName),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.Name)
        };
    }
}