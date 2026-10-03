namespace ErpGovernance.Domain.Entities;

public class CommunicationLog
{
    public int Id { get; set; }
    public int? ActivityId { get; set; }
    public int? ChecklistId { get; set; }
    public string CommunicationType { get; set; } = string.Empty;
    public string? Subject { get; set; }
    public string? Summary { get; set; }
    public string? MomContent { get; set; }
    public DateTime CommunicationDate { get; set; }
    public DateTime? ActualStartDateTime { get; set; }
    public DateTime? ActualEndDateTime { get; set; }
    public string? Participants { get; set; }
    public int? LoggedById { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Activity? Activity { get; set; }
    public Checklist? Checklist { get; set; }
    public AppUser? LoggedBy { get; set; }
}
