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
