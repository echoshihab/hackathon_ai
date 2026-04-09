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
