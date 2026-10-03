using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Domain.Entities;

/// <summary>Base class shared by all hierarchy levels (dates, status, progress, priority, remarks)</summary>
public abstract class HierarchyBase
{
    public int Id { get; set; }
    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public DateOnly? ActualStartDate { get; set; }
    public DateOnly? ActualEndDate { get; set; }
    public ItemStatus Status { get; set; } = ItemStatus.NotStarted;
    public decimal ProgressPercentage { get; set; } = 0;
    public string? Remarks { get; set; }
    public Priority Priority { get; set; } = Priority.Medium;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
