using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Domain.Entities;

public class Project : HierarchyBase
{
    public int OrganizationId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? Description { get; set; }
    public int? CreatedById { get; set; }

    public Organization Organization { get; set; } = null!;
    public AppUser? CreatedBy { get; set; }
    public ICollection<ProjectManager> ProjectManagers { get; set; } = new List<ProjectManager>();
    public ICollection<Module> Modules { get; set; } = new List<Module>();
}
