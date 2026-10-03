namespace ErpGovernance.Domain.Entities;

public class ProjectManager
{
    public int ProjectId { get; set; }
    public int UserId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;

    public Project Project { get; set; } = null!;
    public AppUser User { get; set; } = null!;
}
