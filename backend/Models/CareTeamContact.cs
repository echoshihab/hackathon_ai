namespace backend.Models;

public class CareTeamContact
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Role { get; set; } = ""; // FamilyDoctor | Cardiologist | Pharmacist | Dietician | Other
    public string Name { get; set; } = "";
    public string Contact { get; set; } = "";
}
