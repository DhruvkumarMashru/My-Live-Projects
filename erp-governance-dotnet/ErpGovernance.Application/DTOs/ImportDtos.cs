using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Application.DTOs;

public class ImportRowDto
{
    public string ModuleName { get; set; } = string.Empty;
    public string? ModuleDescription { get; set; }
    public string SubModuleGroupName { get; set; } = string.Empty;
    public string? SubModuleGroupDescription { get; set; }
    public string SubModuleName { get; set; } = string.Empty;
    public string? SubModuleDescription { get; set; }
    public string ChecklistName { get; set; } = string.Empty;
    public string? ChecklistDescription { get; set; }
    public string? ExpectedStartDate { get; set; }
    public string? ExpectedEndDate { get; set; }
    public string? ActualStartDate { get; set; }
    public string? ActualEndDate { get; set; }
    public string? Status { get; set; }
    public string? Priority { get; set; }
    public string? ProgressPercentage { get; set; }
    public string? Remarks { get; set; }
}

public class ImportResultDto
{
    public int TotalRows { get; set; }
    public int ModulesCreated { get; set; }
    public int ModulesUpdated { get; set; }
    public int SubModuleGroupsCreated { get; set; }
    public int SubModuleGroupsUpdated { get; set; }
    public int SubModulesCreated { get; set; }
    public int SubModulesUpdated { get; set; }
    public int ChecklistsCreated { get; set; }
    public int ChecklistsUpdated { get; set; }
    public List<string> Errors { get; set; } = new();
    public bool Success { get; set; }
}

public class ImportRequestDto
{
    [Required]
    public int ProjectId { get; set; }
    public bool UpdateExisting { get; set; }
}
