using ErpGovernance.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Application.DTOs;

public class ActivityFormDto
{
    public int Id { get; set; }

    [Required]
    public int ChecklistId { get; set; }

    [Required, MaxLength(255)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public ActivityType ActivityType { get; set; } = ActivityType.Task;

    public string? ResponsibleTeam { get; set; }

    public int? AssignedUserId { get; set; }

    public string? Participants { get; set; }

    public string? MeetingNotes { get; set; }

    public DateOnly? NextFollowupDate { get; set; }

    [MaxLength(50)]
    public string? EscalationStatus { get; set; }

    public string? Outcome { get; set; }

    public DateTime? ActualStartDateTime { get; set; }
    public DateTime? ActualEndDateTime { get; set; }

    public ItemStatus Status { get; set; } = ItemStatus.NotStarted;
    public Priority Priority { get; set; } = Priority.Medium;

    [Range(0, 100)]
    public decimal ProgressPercentage { get; set; }

    public string? Remarks { get; set; }

    public int? MigrateCommunicationId { get; set; }
}

public class ActivityListDto
{
    public int Id { get; set; }
    public int ChecklistId { get; set; }
    public string ChecklistName { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public ActivityType ActivityType { get; set; }
    public string? AssignedUserName { get; set; }
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public DateTime? ActualStartDateTime { get; set; }
    public DateTime? ActualEndDateTime { get; set; }
    public decimal ProgressPercentage { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class ActivityDetailDto : ActivityFormDto
{
    public string ChecklistName { get; set; } = string.Empty;
    public string? AssignedUserName { get; set; }
    public string? CreatedByName { get; set; }
    public DateTime CreatedAt { get; set; }
}
