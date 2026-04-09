using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.DTOs;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace backend.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IConfiguration _config;
    private readonly IAuditService _audit;

    public AuthController(UserManager<ApplicationUser> userManager, IConfiguration config, IAuditService audit)
    {
        _userManager = userManager;
        _config = config;
        _audit = audit;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var user = new ApplicationUser { UserName = dto.Email, Email = dto.Email };
        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded) return BadRequest(result.Errors);
        return Ok(new { message = "Account created" });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
        {
            await _audit.LogAsync(new AuditLog
            {
                EventType    = "UserAuthentication",
                EventAction  = "E",
                EventOutcome = 4,
                UserName     = dto.Email,
                NetworkAccessPoint = HttpContext.Connection.RemoteIpAddress?.ToString(),
                Controller   = "Auth",
                Action       = "Login",
                HttpMethod   = "POST",
                StatusCode   = 401,
                ErrorMessage = "Invalid credentials"
            });
            return Unauthorized("Invalid credentials");
        }

        var token = GenerateJwt(user);

        await _audit.LogAsync(new AuditLog
        {
            EventType    = "UserAuthentication",
            EventAction  = "E",
            EventOutcome = 0,
            UserId       = user.Id,
            UserName     = user.Email,
            NetworkAccessPoint = HttpContext.Connection.RemoteIpAddress?.ToString(),
            Controller   = "Auth",
            Action       = "Login",
            HttpMethod   = "POST",
            StatusCode   = 200
        });

        return Ok(new { token });
    }

    private string GenerateJwt(ApplicationUser user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Email, user.Email!)
        };
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(double.Parse(_config["Jwt:ExpiryHours"]!)),
            signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
