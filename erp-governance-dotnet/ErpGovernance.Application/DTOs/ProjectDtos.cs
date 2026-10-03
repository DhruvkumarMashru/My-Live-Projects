using ErpGovernance.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Application.DTOs;

public class ProjectListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string OrganizationName { get; set; } = string.Empty;
    public int OrganizationId { get; set; }
    public ItemStatus Status { get; set; }
    public Priority Priority { get; set; }
    public decimal ProgressPercentage { get; set; }
    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public List<string> ManagerNames { get; set; } = new();
    public DateTime CreatedAt { get; set; }
}

public class ProjectFormDto
{
    public int Id { get; set; }

    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(50)]
    public string? Code { get; set; }

    [Required(ErrorMessage = "Organization is required.")]
    public int OrganizationId { get; set; }

    public string? Description { get; set; }
    public ItemStatus Status { get; set; } = ItemStatus.NotStarted;
    public Priority Priority { get; set; } = Priority.Medium;

    public DateOnly? ExpectedStartDate { get; set; }
    public DateOnly? ExpectedEndDate { get; set; }
    public string? Remarks { get; set; }

    public List<int> ManagerIds { get; set; } = new();
}

public class ProjectDetailDto : ProjectListDto
{
    public List<ModuleListDto> Modules { get; set; } = new();
}
