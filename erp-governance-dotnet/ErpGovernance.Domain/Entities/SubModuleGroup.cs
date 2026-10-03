namespace ErpGovernance.Domain.Entities;

/// <summary>Maps to sub_modules table in PHP. Called "Sub Module Group" in UI.</summary>
public class SubModuleGroup : HierarchyBase
{
    public int ModuleId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CreatedById { get; set; }

    public Module Module { get; set; } = null!;
    public AppUser? CreatedBy { get; set; }
    public ICollection<SubModule> SubModules { get; set; } = new List<SubModule>();
}
