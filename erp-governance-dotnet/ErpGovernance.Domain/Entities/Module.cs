namespace ErpGovernance.Domain.Entities;

public class Module : HierarchyBase
{
    public int OrganizationId { get; set; }
    public int ProjectId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CreatedById { get; set; }

    public Organization Organization { get; set; } = null!;
    public Project Project { get; set; } = null!;
    public AppUser? CreatedBy { get; set; }
    public ICollection<SubModuleGroup> SubModuleGroups { get; set; } = new List<SubModuleGroup>();
}
