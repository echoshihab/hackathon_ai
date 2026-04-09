namespace backend.Models;

public class CarePlan
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string TreatmentReceived { get; set; } = "";
    public string Notes { get; set; } = "";
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
