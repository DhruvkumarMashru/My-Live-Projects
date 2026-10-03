using ErpGovernance.Domain.Entities;
using ErpGovernance.Domain.Enums;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Infrastructure.Data;

public class ApplicationDbContext : IdentityDbContext<AppUser, IdentityRole<int>, int>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Organization> Organizations => Set<Organization>();
    public DbSet<Project> Projects => Set<Project>();
    public DbSet<ProjectManager> ProjectManagers => Set<ProjectManager>();
    public DbSet<Module> Modules => Set<Module>();
    public DbSet<SubModuleGroup> SubModuleGroups => Set<SubModuleGroup>();
    public DbSet<SubModule> SubModules => Set<SubModule>();
    public DbSet<Checklist> Checklists => Set<Checklist>();
    public DbSet<Activity> Activities => Set<Activity>();
    public DbSet<CommunicationLog> CommunicationLogs => Set<CommunicationLog>();
    public DbSet<Attachment> Attachments => Set<Attachment>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<StatusHistory> StatusHistories => Set<StatusHistory>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<ChecklistDependency> ChecklistDependencies => Set<ChecklistDependency>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Disable cascade delete to avoid SQL Server cycles
        foreach (var relationship in builder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
        {
            if (!relationship.DeclaringEntityType.ClrType.Name.StartsWith("Identity"))
            {
                relationship.DeleteBehavior = DeleteBehavior.Restrict;
            }
        }

        // ProjectManager composite PK
        builder.Entity<ProjectManager>()
            .HasKey(pm => new { pm.ProjectId, pm.UserId });

        // Enum conversions to string
        builder.Entity<AppUser>()
            .Property(u => u.Role)
            .HasConversion<string>()
            .HasMaxLength(50);

        foreach (var hierarchyType in new[] {
            typeof(Project), typeof(Module), typeof(SubModuleGroup),
            typeof(SubModule), typeof(Checklist), typeof(Activity)
        })
        {
            builder.Entity(hierarchyType)
                .Property("Status")
                .HasConversion<string>()
                .HasMaxLength(50);

            builder.Entity(hierarchyType)
                .Property("Priority")
                .HasConversion<string>()
                .HasMaxLength(20);
        }

        builder.Entity<Activity>()
            .Property(a => a.ActivityType)
            .HasConversion<string>()
            .HasMaxLength(50);

        // Checklist dependency self-referencing
        builder.Entity<ChecklistDependency>()
            .HasOne(d => d.Checklist)
            .WithMany(c => c.Dependencies)
            .HasForeignKey(d => d.ChecklistId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Entity<ChecklistDependency>()
            .HasOne(d => d.DependsOnChecklist)
            .WithMany(c => c.Dependents)
            .HasForeignKey(d => d.DependsOnChecklistId)
            .OnDelete(DeleteBehavior.Restrict);

        // Prevent multiple cascade paths on Activity
        builder.Entity<Activity>()
            .HasOne(a => a.CreatedBy)
            .WithMany()
            .HasForeignKey(a => a.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Entity<Activity>()
            .HasOne(a => a.AssignedUser)
            .WithMany(u => u.AssignedActivities)
            .HasForeignKey(a => a.AssignedUserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Module createdBy
        builder.Entity<Module>()
            .HasOne(m => m.CreatedBy)
            .WithMany()
            .HasForeignKey(m => m.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        // SubModuleGroup
        builder.Entity<SubModuleGroup>()
            .HasOne(s => s.CreatedBy)
            .WithMany()
            .HasForeignKey(s => s.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        // SubModule
        builder.Entity<SubModule>()
            .HasOne(s => s.CreatedBy)
            .WithMany()
            .HasForeignKey(s => s.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        // Checklist
        builder.Entity<Checklist>()
            .HasOne(c => c.CreatedBy)
            .WithMany()
            .HasForeignKey(c => c.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        // CommunicationLog
        builder.Entity<CommunicationLog>()
            .HasOne(c => c.Activity)
            .WithMany(a => a.CommunicationLogs)
            .HasForeignKey(c => c.ActivityId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Entity<CommunicationLog>()
            .HasOne(c => c.Checklist)
            .WithMany(ch => ch.CommunicationLogs)
            .HasForeignKey(c => c.ChecklistId)
            .OnDelete(DeleteBehavior.Restrict);

        // Indexes for performance
        builder.Entity<Module>().HasIndex(m => m.OrganizationId);
        builder.Entity<Module>().HasIndex(m => m.ProjectId);
        builder.Entity<Project>().HasIndex(p => p.OrganizationId);
        builder.Entity<Activity>().HasIndex(a => a.ChecklistId);
        builder.Entity<Activity>().HasIndex(a => a.AssignedUserId);
        builder.Entity<Activity>().HasIndex(a => a.Status);
        builder.Entity<Notification>().HasIndex(n => new { n.UserId, n.IsRead });
        builder.Entity<AuditLog>().HasIndex(a => a.CreatedAt);

        // Rename Identity tables to cleaner names
        builder.Entity<AppUser>().ToTable("Users");
        builder.Entity<IdentityRole<int>>().ToTable("Roles");
        builder.Entity<IdentityUserRole<int>>().ToTable("UserRoles");
        builder.Entity<IdentityUserClaim<int>>().ToTable("UserClaims");
        builder.Entity<IdentityUserLogin<int>>().ToTable("UserLogins");
        builder.Entity<IdentityRoleClaim<int>>().ToTable("RoleClaims");
        builder.Entity<IdentityUserToken<int>>().ToTable("UserTokens");
    }

    public override int SaveChanges()
    {
        UpdateTimestamps();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        UpdateTimestamps();
        return base.SaveChangesAsync(cancellationToken);
    }

    private void UpdateTimestamps()
    {
        var entries = ChangeTracker.Entries()
            .Where(e => e.State == EntityState.Modified);

        foreach (var entry in entries)
        {
            var updatedAt = entry.Properties.FirstOrDefault(p => p.Metadata.Name == "UpdatedAt");
            if (updatedAt != null)
                updatedAt.CurrentValue = DateTime.UtcNow;
        }
    }
}
