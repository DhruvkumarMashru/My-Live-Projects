using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Application.DTOs;

public class ProgressReportDto
{
    public string ProjectName { get; set; } = string.Empty;
    public string ModuleName { get; set; } = string.Empty;
    public string SubModuleGroupName { get; set; } = string.Empty;
    public string SubModuleName { get; set; } = string.Empty;
    public string ChecklistName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
}

public class DelayedItemDto
{
    public string EntityType { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string HierarchyPath { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public int DaysDelayed { get; set; }
}

public class PendingItemDto
{
    public string EntityType { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string HierarchyPath { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public string? AssignedTo { get; set; }
}

public class ResponsibilityItemDto
{
    public string? AssignedUserName { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
}

public class ReportFilterDto
{
    public int? OrgId { get; set; }
    public int? ProjectId { get; set; }
    public string? Status { get; set; }
    public string? Priority { get; set; }
}
