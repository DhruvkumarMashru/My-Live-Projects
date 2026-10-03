using System.ComponentModel.DataAnnotations;

namespace ErpGovernance.Application.DTOs;

public class OrganizationListDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? Address { get; set; }
    public bool IsActive { get; set; }
    public int ProjectCount { get; set; }
    public int UserCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class OrganizationFormDto
{
    public int Id { get; set; }

    [Required, MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(50)]
    public string? Code { get; set; }

    public string? Address { get; set; }
    public bool IsActive { get; set; } = true;
}
