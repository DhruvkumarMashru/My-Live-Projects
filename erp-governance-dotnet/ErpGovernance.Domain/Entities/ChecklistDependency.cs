namespace ErpGovernance.Domain.Entities;

public class ChecklistDependency
{
    public int Id { get; set; }
    public int ChecklistId { get; set; }
    public int DependsOnChecklistId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Checklist Checklist { get; set; } = null!;
    public Checklist DependsOnChecklist { get; set; } = null!;
}
