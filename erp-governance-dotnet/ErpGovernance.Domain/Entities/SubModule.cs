namespace ErpGovernance.Domain.Entities;

/// <summary>Maps to sub_sub_modules table in PHP. Called "Sub Module" in UI.</summary>
public class SubModule : HierarchyBase
{
    public int SubModuleGroupId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CreatedById { get; set; }

    public SubModuleGroup SubModuleGroup { get; set; } = null!;
    public AppUser? CreatedBy { get; set; }
    public ICollection<Checklist> Checklists { get; set; } = new List<Checklist>();
}
