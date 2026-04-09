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
