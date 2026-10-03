using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Domain.Entities;

public class Activity : HierarchyBase
{
    public int ChecklistId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ActivityType ActivityType { get; set; } = ActivityType.Task;
    public string? ResponsibleTeam { get; set; }
    public int? AssignedUserId { get; set; }
    public string? Participants { get; set; }
    public string? CommunicationMode { get; set; }
    public string? MeetingNotes { get; set; }
    public DateOnly? NextFollowupDate { get; set; }
    public string? EscalationStatus { get; set; } = "none";
    public string? Outcome { get; set; }
    public DateTime? ActualStartDateTime { get; set; }
    public DateTime? ActualEndDateTime { get; set; }
    public int? CreatedById { get; set; }
    public int? MigrateCommunicationId { get; set; }

    public Checklist Checklist { get; set; } = null!;
    public AppUser? AssignedUser { get; set; }
    public AppUser? CreatedBy { get; set; }
    public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
    public ICollection<CommunicationLog> CommunicationLogs { get; set; } = new List<CommunicationLog>();
}
