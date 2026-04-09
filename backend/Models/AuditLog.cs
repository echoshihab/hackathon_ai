namespace backend.Models;

/// <summary>
/// ATNA-inspired audit log entry (IHE ITI-20 / RFC 3881).
/// EventActionCode: C=Create, R=Read, U=Update, D=Delete, E=Execute
/// EventOutcome: 0=Success, 4=MinorFailure, 8=SeriousFailure, 12=MajorFailure
/// </summary>
public class AuditLog
{
    public long Id { get; set; }

    // EventIdentification
    public DateTime EventDateTime { get; set; } = DateTime.UtcNow;
    public string EventType { get; set; } = string.Empty;   // e.g. "PHI-Access", "UserAuthentication"
    public string EventAction { get; set; } = string.Empty; // C | R | U | D | E
    public int EventOutcome { get; set; } = 0;              // 0=Success, 4=Minor, 8=Serious, 12=Major

    // ActiveParticipant
    public string? UserId { get; set; }      // JWT sub (GUID)
    public string? UserName { get; set; }    // email
    public string? NetworkAccessPoint { get; set; } // client IP

    // ParticipantObjectIdentification
    public string? ResourceType { get; set; }  // e.g. "Medication", "Appointment"
    public string? ResourceId { get; set; }    // record id if applicable

    // Extended context
    public string Controller { get; set; } = string.Empty;
    public string Action { get; set; } = string.Empty;
    public string HttpMethod { get; set; } = string.Empty;
    public int StatusCode { get; set; }
    public string? ErrorMessage { get; set; }
}
