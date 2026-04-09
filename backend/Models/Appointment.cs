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
