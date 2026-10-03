namespace ErpGovernance.Domain.Entities;

public class Checklist : HierarchyBase
{
    public int SubModuleId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int? CreatedById { get; set; }

    public SubModule SubModule { get; set; } = null!;
    public AppUser? CreatedBy { get; set; }
    public ICollection<Activity> Activities { get; set; } = new List<Activity>();
    public ICollection<CommunicationLog> CommunicationLogs { get; set; } = new List<CommunicationLog>();
    public ICollection<ChecklistDependency> Dependencies { get; set; } = new List<ChecklistDependency>();
    public ICollection<ChecklistDependency> Dependents { get; set; } = new List<ChecklistDependency>();
}
