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
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
}
