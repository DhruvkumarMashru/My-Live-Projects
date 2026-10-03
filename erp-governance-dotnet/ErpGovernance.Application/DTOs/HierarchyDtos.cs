using ErpGovernance.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Application.DTOs;

public abstract class HierarchyCommonFields
{
    public int Id { get; set; }
    public ItemStatus Status { get; set; } = ItemStatus.NotStarted;
    public Priority Priority { get; set; } = Priority.Medium;
    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public DateOnly? ActualStartDate { get; set; }
    public DateOnly? ActualEndDate { get; set; }
    public decimal ProgressPercentage { get; set; }
    public string? Remarks { get; set; }
}

public class ModuleFormDto : HierarchyCommonFields
{
    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    [Required]
    public int ProjectId { get; set; }

    [Required]
    public int OrganizationId { get; set; }
}

public class ModuleListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int ProjectId { get; set; }
    public string ProjectName { get; set; } = string.Empty;
    public int OrganizationId { get; set; }
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public int SubModuleGroupCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class SubModuleGroupFormDto : HierarchyCommonFields
{
    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    [Required]
    public int ModuleId { get; set; }
}

public class SubModuleGroupListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public int SubModuleCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class SubModuleFormDto : HierarchyCommonFields
{
    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    [Required]
    public int SubModuleGroupId { get; set; }
}

public class SubModuleListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int SubModuleGroupId { get; set; }
    public string SubModuleGroupName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public int ChecklistCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class ChecklistFormDto : HierarchyCommonFields
{
    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    [Required]
    public int SubModuleId { get; set; }
}

public class ChecklistListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int SubModuleId { get; set; }
    public string SubModuleName { get; set; } = string.Empty;
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public int ActivityCount { get; set; }
    public DateTime CreatedAt { get; set; }
}
