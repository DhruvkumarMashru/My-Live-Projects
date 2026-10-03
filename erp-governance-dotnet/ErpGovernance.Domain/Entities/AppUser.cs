using Microsoft.AspNetCore.Identity;
using ErpGovernance.Domain.Enums;

namespace ErpGovernance.Domain.Entities;

public class AppUser : IdentityUser<int>
{
    public int? OrganizationId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public UserRole Role { get; set; } = UserRole.Viewer;
    public string? Phone { get; set; }
    public string? Department { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? LastLogin { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Organization? Organization { get; set; }
    public ICollection<ProjectManager> ManagedProjects { get; set; } = new List<ProjectManager>();
    public ICollection<Activity> AssignedActivities { get; set; } = new List<Activity>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}
