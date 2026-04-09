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
