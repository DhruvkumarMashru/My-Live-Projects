using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Application.DTOs;

public class DashboardSummaryDto
{
    public int TotalProjects { get; set; }
    public int TotalModules { get; set; }
    public int TotalSubModuleGroups { get; set; }
    public int TotalSubModules { get; set; }
    public int TotalChecklists { get; set; }
    public int TotalActivities { get; set; }
    public int DelayedItems { get; set; }
    public int CompletedChecklists { get; set; }
}

public class ProjectTreeDto
{
    public int ProjectId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string OrganizationName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public List<string> ManagerNames { get; set; } = new();
    public List<ModuleTreeDto> Modules { get; set; } = new();
}

public class ModuleTreeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public decimal ProgressPercentage { get; set; }
    public List<SubModuleGroupTreeDto> SubModuleGroups { get; set; } = new();
}

public class SubModuleGroupTreeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public decimal ProgressPercentage { get; set; }
    public List<SubModuleTreeDto> SubModules { get; set; } = new();
}

public class SubModuleTreeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public decimal ProgressPercentage { get; set; }
    public List<ChecklistTreeDto> Checklists { get; set; } = new();
}

public class ChecklistTreeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public List<ActivitySummaryDto> Activities { get; set; } = new();
}

public class ActivitySummaryDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string ActivityTypeDisplay { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public string? AssignedUserName { get; set; }
    public DateTime? ActualStartDateTime { get; set; }
    public DateTime? ActualEndDateTime { get; set; }
}

public class DashboardFilterDto
{
    public int? OrgId { get; set; }
    public int? ProjectId { get; set; }
}
