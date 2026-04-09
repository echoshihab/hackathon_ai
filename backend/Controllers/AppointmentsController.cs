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
            AppointmentDate = DateTime.SpecifyKind(dto.AppointmentDate, DateTimeKind.Utc),
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
