using ErpGovernance.Application.Interfaces;
using ErpGovernance.Domain.Enums;
using ErpGovernance.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ErpGovernance.Infrastructure.Services;

/// <summary>
/// Propagates progress percentages and status values upward through the full hierarchy:
/// Checklist → SubModule → SubModuleGroup → Module → Project.
///
/// Status mapping:
///   0%           → NotStarted
///   0% &lt; x &lt; 100% → InProgress
///   100%         → Completed
///
/// A single <see cref="ApplicationDbContext.SaveChangesAsync"/> is called at the end
/// of each public method to batch all mutations into one round-trip.
/// </summary>
public sealed class ProgressRollupService : IProgressRollupService
{
    /// <inheritdoc/>
    public async Task RecalcFromChecklistAsync(int checklistId, ApplicationDbContext db)
    {
        // ── Step 1: Resolve the checklist's parent SubModule ──────────────────
        var checklist = await db.Checklists
            .AsNoTracking()
            .Where(c => c.Id == checklistId)
            .Select(c => new { c.Id, c.SubModuleId })
            .FirstOrDefaultAsync();

        if (checklist is null)
            return;

        // ── Step 2: Recalc SubModule → get parent SubModuleGroupId ────────────
        var subModuleGroupId = await RecalcSubModuleInternalAsync(checklist.SubModuleId, db);
        if (subModuleGroupId == 0)
            return;

        // ── Step 3: Recalc SubModuleGroup → get parent ModuleId ───────────────
        var moduleId = await RecalcSubModuleGroupInternalAsync(subModuleGroupId, db);
        if (moduleId == 0)
            return;

        // ── Step 4: Recalc Module → get parent ProjectId ──────────────────────
        var projectId = await RecalcModuleInternalAsync(moduleId, db);
        if (projectId == 0)
            return;

        // ── Step 5: Recalc Project ────────────────────────────────────────────
        await RecalcProjectInternalAsync(projectId, db);

        // ── Single flush for all mutations ────────────────────────────────────
        await db.SaveChangesAsync();
    }

    /// <inheritdoc/>
    public async Task RecalcFromModuleAsync(int moduleId, ApplicationDbContext db)
    {
        // ── Recalc Module → get parent ProjectId ──────────────────────────────
        var projectId = await RecalcModuleInternalAsync(moduleId, db);
        if (projectId == 0)
            return;

        // ── Recalc Project ────────────────────────────────────────────────────
        await RecalcProjectInternalAsync(projectId, db);

        // ── Single flush ──────────────────────────────────────────────────────
        await db.SaveChangesAsync();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Internal roll-up helpers — mutate tracked entities, do NOT SaveChanges
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Averages all Checklist.ProgressPercentage values in the given SubModule,
    /// updates the SubModule entity (tracked), and returns the parent SubModuleGroupId.
    /// </summary>
    private static async Task<int> RecalcSubModuleInternalAsync(int subModuleId, ApplicationDbContext db)
    {
        // Aggregate in the database — avoids loading all checklist rows
        var avg = await db.Checklists
            .Where(c => c.SubModuleId == subModuleId)
            .Select(c => (double?)c.ProgressPercentage)
            .AverageAsync() ?? 0.0;

        var subModule = await db.SubModules.FindAsync(subModuleId);
        if (subModule is null)
            return 0;

        subModule.ProgressPercentage = Math.Round((decimal)avg, 2);
        subModule.Status             = DeriveStatus(subModule.ProgressPercentage);
        subModule.UpdatedAt          = DateTime.UtcNow;

        return subModule.SubModuleGroupId;
    }

    /// <summary>
    /// Averages all SubModule.ProgressPercentage values in the given SubModuleGroup,
    /// updates the SubModuleGroup entity (tracked), and returns the parent ModuleId.
    /// </summary>
    private static async Task<int> RecalcSubModuleGroupInternalAsync(int subModuleGroupId, ApplicationDbContext db)
    {
        var avg = await db.SubModules
            .Where(sm => sm.SubModuleGroupId == subModuleGroupId)
            .Select(sm => (double?)sm.ProgressPercentage)
            .AverageAsync() ?? 0.0;

        var group = await db.SubModuleGroups.FindAsync(subModuleGroupId);
        if (group is null)
            return 0;

        group.ProgressPercentage = Math.Round((decimal)avg, 2);
        group.Status             = DeriveStatus(group.ProgressPercentage);
        group.UpdatedAt          = DateTime.UtcNow;

        return group.ModuleId;
    }

    /// <summary>
    /// Averages all SubModuleGroup.ProgressPercentage values in the given Module,
    /// updates the Module entity (tracked), and returns the parent ProjectId.
    /// </summary>
    private static async Task<int> RecalcModuleInternalAsync(int moduleId, ApplicationDbContext db)
    {
        var avg = await db.SubModuleGroups
            .Where(g => g.ModuleId == moduleId)
            .Select(g => (double?)g.ProgressPercentage)
            .AverageAsync() ?? 0.0;

        var module = await db.Modules.FindAsync(moduleId);
        if (module is null)
            return 0;

        module.ProgressPercentage = Math.Round((decimal)avg, 2);
        module.Status             = DeriveStatus(module.ProgressPercentage);
        module.UpdatedAt          = DateTime.UtcNow;

        return module.ProjectId;
    }

    /// <summary>
    /// Averages all Module.ProgressPercentage values in the given Project
    /// and updates the Project entity (tracked).
    /// </summary>
    private static async Task RecalcProjectInternalAsync(int projectId, ApplicationDbContext db)
    {
        var avg = await db.Modules
            .Where(m => m.ProjectId == projectId)
            .Select(m => (double?)m.ProgressPercentage)
            .AverageAsync() ?? 0.0;

        var project = await db.Projects.FindAsync(projectId);
        if (project is null)
            return;

        project.ProgressPercentage = Math.Round((decimal)avg, 2);
        project.Status             = DeriveStatus(project.ProgressPercentage);
        project.UpdatedAt          = DateTime.UtcNow;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Status derivation
    // ─────────────────────────────────────────────────────────────────────────

    private static ItemStatus DeriveStatus(decimal progress) => progress switch
    {
        <= 0m   => ItemStatus.NotStarted,
        >= 100m => ItemStatus.Completed,
        _       => ItemStatus.InProgress
    };
}
