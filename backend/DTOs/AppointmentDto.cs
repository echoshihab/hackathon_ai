namespace backend.DTOs;

public class AppointmentDto
{
    public DateTime AppointmentDate { get; set; }
    public string ProviderName { get; set; } = "";
    public string Purpose { get; set; } = "";
    public string Notes { get; set; } = "";
}
