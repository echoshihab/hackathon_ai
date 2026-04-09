$ErrorActionPreference = "Stop"
$root = "C:\Users\echos\source\repos\hackathon_ai\backend"

Write-Host "=== Scaffolding .NET 9 Web API ===" -ForegroundColor Cyan

# 1. Scaffold project
dotnet new webapi -n backend --framework net9.0 --output $root --force

Set-Location $root

# 2. Add packages
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Swashbuckle.AspNetCore

# 3. Create folder structure
New-Item -ItemType Directory -Path "$root\Controllers" -Force | Out-Null
New-Item -ItemType Directory -Path "$root\Models"      -Force | Out-Null
New-Item -ItemType Directory -Path "$root\Data"        -Force | Out-Null
New-Item -ItemType Directory -Path "$root\DTOs"        -Force | Out-Null

# ──────────────────────────────────────────────────────────────────────────────
# 4. Models
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\Models\ApplicationUser.cs" @'
using Microsoft.AspNetCore.Identity;

namespace backend.Models;

public class ApplicationUser : IdentityUser
{
}
'@

Set-Content "$root\Models\CarePlan.cs" @'
namespace backend.Models;

public class CarePlan
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string TreatmentReceived { get; set; } = "";
    public string Notes { get; set; } = "";
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
'@

Set-Content "$root\Models\Medication.cs" @'
namespace backend.Models;

public class Medication
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Name { get; set; } = "";
    public string Reason { get; set; } = "";
    public string DosageInstructions { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
'@

Set-Content "$root\Models\Appointment.cs" @'
namespace backend.Models;

public class Appointment
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public DateTime AppointmentDate { get; set; }
    public string ProviderName { get; set; } = "";
    public string Purpose { get; set; } = "";
    public string Notes { get; set; } = "";
}
'@

Set-Content "$root\Models\LifestyleGoal.cs" @'
namespace backend.Models;

public class LifestyleGoal
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Category { get; set; } = "";
    public string Text { get; set; } = "";
    public bool IsCompleted { get; set; } = false;
}
'@

Set-Content "$root\Models\CareTeamContact.cs" @'
namespace backend.Models;

public class CareTeamContact
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Role { get; set; } = "";
    public string Name { get; set; } = "";
    public string Contact { get; set; } = "";
}
'@

# ──────────────────────────────────────────────────────────────────────────────
# 5. Data
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\Data\AppDbContext.cs" @'
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using backend.Models;

namespace backend.Data;

public class AppDbContext : IdentityDbContext<ApplicationUser>
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

    public DbSet<Medication> Medications => Set<Medication>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<LifestyleGoal> LifestyleGoals => Set<LifestyleGoal>();
    public DbSet<CareTeamContact> CareTeamContacts => Set<CareTeamContact>();
    public DbSet<CarePlan> CarePlans => Set<CarePlan>();
}
'@

# ──────────────────────────────────────────────────────────────────────────────
# 6. DTOs
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\DTOs\RegisterDto.cs" @'
namespace backend.DTOs;

public class RegisterDto
{
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
}
'@

Set-Content "$root\DTOs\LoginDto.cs" @'
namespace backend.DTOs;

public class LoginDto
{
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
}
'@

Set-Content "$root\DTOs\CarePlanDto.cs" @'
namespace backend.DTOs;

public class CarePlanDto
{
    public string TreatmentReceived { get; set; } = "";
    public string Notes { get; set; } = "";
}
'@

Set-Content "$root\DTOs\MedicationDto.cs" @'
namespace backend.DTOs;

public class MedicationDto
{
    public string Name { get; set; } = "";
    public string Reason { get; set; } = "";
    public string DosageInstructions { get; set; } = "";
}
'@

Set-Content "$root\DTOs\AppointmentDto.cs" @'
namespace backend.DTOs;

public class AppointmentDto
{
    public DateTime AppointmentDate { get; set; }
    public string ProviderName { get; set; } = "";
    public string Purpose { get; set; } = "";
    public string Notes { get; set; } = "";
}
'@

Set-Content "$root\DTOs\LifestyleGoalDto.cs" @'
namespace backend.DTOs;

public class LifestyleGoalDto
{
    public string Category { get; set; } = "";
    public string Text { get; set; } = "";
}
'@

Set-Content "$root\DTOs\CareTeamContactDto.cs" @'
namespace backend.DTOs;

public class CareTeamContactDto
{
    public string Role { get; set; } = "";
    public string Name { get; set; } = "";
    public string Contact { get; set; } = "";
}
'@

# ──────────────────────────────────────────────────────────────────────────────
# 7. Controllers
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\Controllers\AuthController.cs" @'
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using backend.DTOs;
using backend.Models;
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

    public AuthController(UserManager<ApplicationUser> userManager, IConfiguration config)
    {
        _userManager = userManager;
        _config = config;
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
            return Unauthorized("Invalid credentials");

        var token = GenerateJwt(user);
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
'@

Set-Content "$root\Controllers\CarePlanController.cs" @'
using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/careplan")]
[Authorize]
public class CarePlanController : ControllerBase
{
    private readonly AppDbContext _db;
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

    public CarePlanController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var plan = await _db.CarePlans.FirstOrDefaultAsync(c => c.UserId == UserId);
        if (plan == null) return Ok(new CarePlan { UserId = UserId });
        return Ok(plan);
    }

    [HttpPut]
    public async Task<IActionResult> Update(CarePlanDto dto)
    {
        var plan = await _db.CarePlans.FirstOrDefaultAsync(c => c.UserId == UserId);
        if (plan == null)
        {
            plan = new CarePlan { UserId = UserId };
            _db.CarePlans.Add(plan);
        }
        plan.TreatmentReceived = dto.TreatmentReceived;
        plan.Notes = dto.Notes;
        plan.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(plan);
    }
}
'@

Set-Content "$root\Controllers\MedicationsController.cs" @'
using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/medications")]
[Authorize]
public class MedicationsController : ControllerBase
{
    private readonly AppDbContext _db;
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

    public MedicationsController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _db.Medications.Where(m => m.UserId == UserId).ToListAsync());

    [HttpPost]
    public async Task<IActionResult> Create(MedicationDto dto)
    {
        var med = new Medication
        {
            UserId = UserId,
            Name = dto.Name,
            Reason = dto.Reason,
            DosageInstructions = dto.DosageInstructions
        };
        _db.Medications.Add(med);
        await _db.SaveChangesAsync();
        return Ok(med);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var med = await _db.Medications.FirstOrDefaultAsync(m => m.Id == id && m.UserId == UserId);
        if (med == null) return NotFound();
        _db.Medications.Remove(med);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
'@

Set-Content "$root\Controllers\AppointmentsController.cs" @'
using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/appointments")]
[Authorize]
public class AppointmentsController : ControllerBase
{
    private readonly AppDbContext _db;
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

    public AppointmentsController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _db.Appointments.Where(a => a.UserId == UserId).OrderBy(a => a.AppointmentDate).ToListAsync());

    [HttpPost]
    public async Task<IActionResult> Create(AppointmentDto dto)
    {
        var appt = new Appointment
        {
            UserId = UserId,
            AppointmentDate = dto.AppointmentDate,
            ProviderName = dto.ProviderName,
            Purpose = dto.Purpose,
            Notes = dto.Notes
        };
        _db.Appointments.Add(appt);
        await _db.SaveChangesAsync();
        return Ok(appt);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var appt = await _db.Appointments.FirstOrDefaultAsync(a => a.Id == id && a.UserId == UserId);
        if (appt == null) return NotFound();
        _db.Appointments.Remove(appt);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
'@

Set-Content "$root\Controllers\LifestyleController.cs" @'
using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/lifestyle")]
[Authorize]
public class LifestyleController : ControllerBase
{
    private readonly AppDbContext _db;
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

    public LifestyleController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _db.LifestyleGoals.Where(g => g.UserId == UserId).ToListAsync());

    [HttpPost]
    public async Task<IActionResult> Create(LifestyleGoalDto dto)
    {
        var goal = new LifestyleGoal
        {
            UserId = UserId,
            Category = dto.Category,
            Text = dto.Text
        };
        _db.LifestyleGoals.Add(goal);
        await _db.SaveChangesAsync();
        return Ok(goal);
    }

    [HttpPatch("{id}/toggle")]
    public async Task<IActionResult> Toggle(int id)
    {
        var goal = await _db.LifestyleGoals.FirstOrDefaultAsync(g => g.Id == id && g.UserId == UserId);
        if (goal == null) return NotFound();
        goal.IsCompleted = !goal.IsCompleted;
        await _db.SaveChangesAsync();
        return Ok(goal);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var goal = await _db.LifestyleGoals.FirstOrDefaultAsync(g => g.Id == id && g.UserId == UserId);
        if (goal == null) return NotFound();
        _db.LifestyleGoals.Remove(goal);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
'@

Set-Content "$root\Controllers\CareTeamController.cs" @'
using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/careteam")]
[Authorize]
public class CareTeamController : ControllerBase
{
    private readonly AppDbContext _db;
    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

    public CareTeamController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _db.CareTeamContacts.Where(c => c.UserId == UserId).ToListAsync());

    [HttpPost]
    public async Task<IActionResult> Create(CareTeamContactDto dto)
    {
        var contact = new CareTeamContact
        {
            UserId = UserId,
            Role = dto.Role,
            Name = dto.Name,
            Contact = dto.Contact
        };
        _db.CareTeamContacts.Add(contact);
        await _db.SaveChangesAsync();
        return Ok(contact);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var contact = await _db.CareTeamContacts.FirstOrDefaultAsync(c => c.Id == id && c.UserId == UserId);
        if (contact == null) return NotFound();
        _db.CareTeamContacts.Remove(contact);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
'@

# ──────────────────────────────────────────────────────────────────────────────
# 8. appsettings.json
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\appsettings.json" @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "Default": "Host=localhost;Database=ccs_heartattack;Username=postgres;Password=postgres"
  },
  "Jwt": {
    "Key": "ccs-hackathon-secret-key-minimum-32-characters-long",
    "Issuer": "ccs-api",
    "Audience": "ccs-app",
    "ExpiryHours": "24"
  }
}
'@

# ──────────────────────────────────────────────────────────────────────────────
# 9. Program.cs
# ──────────────────────────────────────────────────────────────────────────────
Set-Content "$root\Program.cs" @'
using System.Text;
using backend.Data;
using backend.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opt =>
    {
        opt.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddCors(opt => opt.AddPolicy("Dev", p =>
    p.WithOrigins("http://localhost:5173").AllowAnyHeader().AllowAnyMethod()));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "CCS API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("Dev");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
'@

# ──────────────────────────────────────────────────────────────────────────────
# 10. Build
# ──────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== Building project ===" -ForegroundColor Cyan
dotnet build
Write-Host "`n=== Setup complete! ===" -ForegroundColor Green
Write-Host "Run migrations with:" -ForegroundColor Yellow
Write-Host "  dotnet ef migrations add InitialCreate" -ForegroundColor Yellow
Write-Host "  dotnet ef database update" -ForegroundColor Yellow
